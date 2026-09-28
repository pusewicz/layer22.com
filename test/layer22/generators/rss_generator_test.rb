# frozen_string_literal: true

require "test_helper"

module Layer22
  module Generators
    class RssGeneratorTest < TestCase
      NS = {
        "atom" => "http://www.w3.org/2005/Atom",
        "content" => "http://purl.org/rss/1.0/modules/content/",
        "dc" => "http://purl.org/dc/elements/1.1/"
      }.freeze
      RFC822_TIME = /\A[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} \d{2}:\d{2}:\d{2} [+-]\d{4}\z/

      def test_channels_are_the_posts_and_the_notes
        posts, notes = RssGenerator.channels(fixture_site)

        assert_equal "/rss.xml", posts.path
        assert_equal "fixture|site", posts.title
        assert_equal "Fixture description", posts.description
        assert_equal "/", posts.link
        assert_equal fixture_site.posts, posts.items
        assert_equal "/notes/feed.xml", notes.path
        assert_equal "fixture|site · Notes", notes.title
        assert_equal "Short notes and links from Ada Author", notes.description
        assert_equal "/notes/", notes.link
        assert_equal fixture_site.notes, notes.items
      end

      def test_posts_channel_describes_the_site
        channel = feed(:posts).at_xpath("/rss/channel")

        assert_equal "2.0", feed(:posts).at_xpath("/rss")["version"]
        assert_equal "fixture|site", channel.at_xpath("title").text
        assert_equal "https://example.test/", channel.at_xpath("link").text
        assert_equal "Fixture description", channel.at_xpath("description").text
        assert_equal "en-US", channel.at_xpath("language").text
        assert_equal "ada@example.test (Ada Author)", channel.at_xpath("managingEditor").text
        assert_equal "ada@example.test (Ada Author)", channel.at_xpath("webMaster").text
      end

      def test_channel_links_to_itself
        posts = feed(:posts).at_xpath("/rss/channel/atom:link", NS)
        notes = feed(:notes).at_xpath("/rss/channel/atom:link", NS)

        assert_equal "https://example.test/rss.xml", posts["href"]
        assert_equal "self", posts["rel"]
        assert_equal "application/rss+xml", posts["type"]
        assert_equal "https://example.test/notes/feed.xml", notes["href"]
      end

      def test_channel_dates_are_rfc822_timestamps
        channel = feed(:posts).at_xpath("/rss/channel")

        assert_match RFC822_TIME, channel.at_xpath("lastBuildDate").text
        assert_match RFC822_TIME, channel.at_xpath("pubDate").text
      end

      def test_notes_channel_describes_the_notes
        channel = feed(:notes).at_xpath("/rss/channel")

        assert_equal "fixture|site · Notes", channel.at_xpath("title").text
        assert_equal "https://example.test/notes/", channel.at_xpath("link").text
        assert_equal "Short notes and links from Ada Author", channel.at_xpath("description").text
      end

      def test_post_items_are_newest_first_with_absolute_links
        items = feed(:posts).xpath("/rss/channel/item")

        assert_equal %w[https://example.test/cafe https://example.test/review https://example.test/hello-world],
          items.map { |item| item.at_xpath("link").text }
        assert_equal items.map { |item| item.at_xpath("link").text }, items.map { |item| item.at_xpath("guid").text }
        assert(items.all? { |item| item.at_xpath("guid")["isPermaLink"] == "true" })
      end

      def test_post_item_fields
        item = item_for(:posts, "review")

        assert_equal "Year — in review", item.at_xpath("title").text
        assert_equal "Fri, 01 Jan 2021 00:30:00 +0100", item.at_xpath("pubDate").text
        assert_equal "Ada Author", item.at_xpath("dc:creator", NS).text
        assert_equal "Written late on New Year’s Eve, UTC: “quoted” text – and an ellipsis… Raw HTML stays.", item.at_xpath("description").text
        assert_equal ["ruby"], item.xpath("category").map(&:text)
      end

      def test_post_item_categories_are_its_tags_only
        assert_equal %w[ruby rails], item_for(:posts, "hello-world").xpath("category").map(&:text)
        assert_equal %w[ruby Café], item_for(:posts, "cafe").xpath("category").map(&:text)
      end

      def test_item_content_is_html_in_cdata
        content = item_for(:posts, "hello-world").at_xpath("content:encoded", NS)

        assert(content.children.any?(&:cdata?))
        html = parse_html(content.text)
        assert_equal "a reference link", html.at_css("a[href='https://example.test/reference']").text
      end

      def test_item_content_links_and_images_are_made_absolute
        html = parse_html(content_of(item_for(:posts, "hello-world")))

        assert_equal "https://example.test/images/notes/wide.png", html.at_css("img")["src"]
      end

      def test_item_content_makes_root_relative_links_absolute
        with_site({"_posts/2021-03-01-links.md" => "---\ntitle: Links\n---\n\nSee [about](/about) and [outside](https://elsewhere.test/x).\n"}) do
          html = parse_html(content_of(item(:posts, loaded_site, "links")))

          assert_equal %w[https://example.test/about https://elsewhere.test/x], html.css("a").map { |a| a["href"] }
        end
      end

      def test_item_description_is_plain_text_of_the_content
        description = item_for(:posts, "hello-world").at_xpath("description").text

        assert description.start_with?("This is the first paragraph of the first post. It has a reference link and inline code.")
        assert_equal description.strip, description
        refute_match(/[<>]/, description)
      end

      def test_item_description_is_truncated_to_400_characters
        with_site({
          "_notes/2021/05/2021-05-01-long.md" => "---\ndate: 2021-05-01 10:00:00 +0200\n---\n\n#{"a" * 450}\n",
          "_notes/2021/05/2021-05-02-exact.md" => "---\ndate: 2021-05-02 10:00:00 +0200\n---\n\n#{"b" * 400}\n",
          "_notes/2021/05/2021-05-03-short.md" => "---\ndate: 2021-05-03 10:00:00 +0200\n---\n\n#{"c" * 399}\n"
        }) do
          site = loaded_site
          descriptions = feed_for(:notes, site).xpath("/rss/channel/item/description").map(&:text)

          assert_equal ["c" * 399, "b" * 400, "#{"a" * 397}..."], descriptions
        end
      end

      def test_content_containing_a_cdata_terminator_round_trips_exactly
        html = %(<div data-x="]]>" data-y="a ]]> b ]]> c">body</div>)
        with_site({
          "_posts/2021-03-01-tricky.md" => "---\ntitle: Tricky\n---\n\n#{html}\n",
          "_notes/2021/05/2021-05-01-tricky.md" => "---\ndate: 2021-05-01 10:00:00 +0200\n---\n\n#{html}\n"
        }) do
          site = loaded_site

          assert_includes site.posts.first.body_html, "]]>"
          assert_equal site.posts.first.body_html.strip, content_of(feed_for(:posts, site).at_xpath("/rss/channel/item"))
          assert_equal site.notes.first.body_html.strip, content_of(feed_for(:notes, site).at_xpath("/rss/channel/item"))
        end
      end

      def test_untitled_notes_have_no_title_element
        items = feed(:notes).xpath("/rss/channel/item")

        assert_equal 6, items.size
        assert(items.none? { |item| item.at_xpath("title") })
      end

      def test_note_items_are_newest_first
        links = feed(:notes).xpath("/rss/channel/item/link").map(&:text)

        assert_equal %w[070000 200000 080000 121000 101500 093000], links.map { |link| link[%r{/(\d{6})/\z}, 1] }
      end

      def test_note_item_publication_dates_keep_the_offset
        assert_equal "Thu, 06 May 2021 07:00:00 +0200", item_for(:notes, "notes/2021/05/06/070000").at_xpath("pubDate").text
      end

      def test_note_categories_are_its_tags
        assert_equal ["misc"], item_for(:notes, "notes/2021/05/01/093000").xpath("category").map(&:text)
        assert_empty item_for(:notes, "notes/2021/05/02/101500").xpath("category")
      end

      def test_plain_note_content_has_no_card
        content = content_of(item_for(:notes, "notes/2021/05/01/093000"))

        assert_equal "<p>A plain note with <em>no</em> link.</p>", content
      end

      def test_link_note_content_gets_its_link_card_appended
        content = content_of(item_for(:notes, "notes/2021/05/02/101500"))

        assert content.start_with?("<p>Look at this.</p>")
        card = parse_html(content).at_css("a.link-card")
        assert_equal "https://www.example.org/wide", card["href"]
        assert_includes card.text, "A wide preview"
        assert_equal "https://example.test/images/notes/wide.png", card.at_css("img")["src"]
      end

      def test_square_link_note_thumbnail_is_absolute
        content = content_of(item_for(:notes, "notes/2021/05/03/121000"))

        assert_equal "https://example.test/images/notes/square.png", parse_html(content).at_css("a.link-card img")["src"]
      end

      def test_link_only_note_content_is_just_the_card
        content = content_of(item_for(:notes, "notes/2021/05/05/200000"))

        html = parse_html(content)
        assert_equal ["a"], html.at_css("body").children.map(&:name)
        assert_equal "https://example.com/only-a-link", html.at_css("a.link-card")["href"]
        assert_includes html.text, "Only a link"
      end

      def test_youtube_note_content_gets_the_feed_youtube_card
        content = content_of(item_for(:notes, "notes/2021/05/04/080000"))

        html = parse_html(content)
        assert content.start_with?("<p>Watch this.</p>")
        assert_equal "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg", html.at_css(".youtube-card img")["src"]
        assert_equal ["https://www.youtube.com/watch?v=dQw4w9WgXcQ"], html.css(".youtube-card a").map { |a| a["href"] }.uniq
        assert_nil html.at_css("iframe")
      end

      def test_link_note_description_includes_the_card_text
        description = item_for(:notes, "notes/2021/05/04/080000").at_xpath("description").text

        assert_includes description, "Watch this."
        assert_includes description, "A video"
      end

      def test_feed_lists_only_the_ten_newest_items
        notes = (1..12).to_h do |day|
          stamp = format("2021-05-%02d", day)
          ["_notes/2021/05/#{stamp}-note.md", "---\ndate: #{stamp} 10:00:00 +0200\n---\n\nNote #{day}.\n"]
        end
        with_site(notes) do
          descriptions = feed_for(:notes, loaded_site).xpath("/rss/channel/item/description").map(&:text)

          assert_equal (3..12).to_a.reverse.map { |day| "Note #{day}." }, descriptions
        end
      end

      def test_generate_writes_each_channel_at_its_path
        Dir.mktmpdir do |dir|
          out, = capture_io do
            RssGenerator.channels(fixture_site).each { |channel| RssGenerator.new(fixture_site, channel).generate(output_dir: dir) }
          end

          assert_includes out, "Generated #{File.join(dir, "rss.xml")}"
          assert_includes out, "Generated #{File.join(dir, "notes", "feed.xml")}"
          assert_equal 3, parse_xml(File.read(File.join(dir, "rss.xml"))).xpath("/rss/channel/item").size
          assert_equal 6, parse_xml(File.read(File.join(dir, "notes", "feed.xml"))).xpath("/rss/channel/item").size
        end
      end

      def test_feed_without_items_is_still_a_valid_channel
        with_site do
          doc = feed_for(:posts, loaded_site)

          assert_empty doc.xpath("/rss/channel/item")
          assert_equal "fixture|site", doc.at_xpath("/rss/channel/title").text
        end
      end

      def test_titles_are_smartified
        with_site({"_posts/2021-03-01-quotes.md" => "---\ntitle: \"Don't stop -- ever...\"\n---\n\nBody.\n"}) do
          title = item(:posts, loaded_site, "quotes").at_xpath("title").text

          assert_equal "Don’t stop – ever…", title
        end
      end

      private

      def loaded_site
        Site.new.load_content
      end

      def content_of(item)
        item.at_xpath("content:encoded", NS).text.strip
      end

      def channel_for(name, site)
        RssGenerator.channels(site).fetch({posts: 0, notes: 1}.fetch(name))
      end

      def feed_for(name, site)
        parse_xml(RssGenerator.new(site, channel_for(name, site)).build_feed)
      end

      def feed(name)
        feed_for(name, fixture_site)
      end

      def item(name, site, slug)
        feed_for(name, site).at_xpath("/rss/channel/item[link='https://example.test/#{item_path(name, slug)}']")
      end

      def item_for(name, slug)
        item(name, fixture_site, slug)
      end

      def item_path(name, slug)
        (name == :notes) ? "#{slug}/" : slug
      end
    end
  end
end
