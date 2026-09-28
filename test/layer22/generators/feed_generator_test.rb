# frozen_string_literal: true

require "test_helper"

module Layer22
  module Generators
    class FeedGeneratorTest < TestCase
      ATOM = {"a" => "http://www.w3.org/2005/Atom"}.freeze
      XMLSCHEMA_TIME = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}\z/

      def test_feed_describes_the_site
        feed = atom(fixture_site).root

        assert_equal "http://www.w3.org/2005/Atom", feed.namespace.href
        assert_equal "https://example.test/feed.xml", feed.at_xpath("a:id", ATOM).text
        assert_equal "fixture|site", feed.at_xpath("a:title", ATOM).text
        assert_equal "html", feed.at_xpath("a:title", ATOM)["type"]
        assert_equal "Fixture description", feed.at_xpath("a:subtitle", ATOM).text
        assert_equal "Ada Author", feed.at_xpath("a:author/a:name", ATOM).text
        assert_equal "ada@example.test", feed.at_xpath("a:author/a:email", ATOM).text
      end

      def test_feed_links_to_itself_and_to_the_site
        feed = atom(fixture_site).root

        self_link = feed.at_xpath("a:link[@rel='self']", ATOM)
        assert_equal "https://example.test/feed.xml", self_link["href"]
        assert_equal "application/atom+xml", self_link["type"]
        alternate = feed.at_xpath("a:link[@rel='alternate']", ATOM)
        assert_equal "https://example.test/", alternate["href"]
        assert_equal "text/html", alternate["type"]
      end

      def test_feed_updated_time_is_an_xml_schema_timestamp
        assert_match XMLSCHEMA_TIME, atom(fixture_site).at_xpath("/a:feed/a:updated", ATOM).text
      end

      def test_entries_are_newest_first
        ids = atom(fixture_site).xpath("/a:feed/a:entry/a:id", ATOM).map(&:text)

        assert_equal %w[https://example.test/cafe https://example.test/review https://example.test/hello-world], ids
      end

      def test_entry_links_are_absolute
        entry = entry_for("review")

        assert_equal "https://example.test/review", entry.at_xpath("a:id", ATOM).text
        link = entry.at_xpath("a:link", ATOM)
        assert_equal "https://example.test/review", link["href"]
        assert_equal "alternate", link["rel"]
        assert_equal "text/html", link["type"]
        assert_equal "https://example.test/review", entry.at_xpath("a:content", ATOM).attribute_with_ns("base", "http://www.w3.org/XML/1998/namespace").value
      end

      def test_entry_dates_carry_the_sites_timezone_offset
        entry = entry_for("review")

        assert_equal "2021-01-01T00:30:00+01:00", entry.at_xpath("a:published", ATOM).text
        assert_equal "2021-01-05T09:00:00+01:00", entry.at_xpath("a:updated", ATOM).text
        assert_equal "2021-06-01T00:00:00+02:00", entry_for("cafe").at_xpath("a:published", ATOM).text
      end

      def test_entry_categories_precede_tags
        assert_equal %w[code ruby rails], terms(entry_for("hello-world"))
        assert_equal %w[life ruby], terms(entry_for("review"))
      end

      def test_entry_without_categories_lists_only_tags
        assert_equal %w[ruby Café], terms(entry_for("cafe"))
      end

      def test_entry_content_is_html_in_cdata
        content = entry_for("hello-world").at_xpath("a:content", ATOM)

        assert_equal "html", content["type"]
        assert_predicate content.children.first, :cdata?
        html = parse_html(content.text)
        assert_equal "a reference link", html.at_css("a[href='https://example.test/reference']").text
        assert_equal "/images/notes/wide.png", html.at_css("img")["src"]
      end

      def test_entry_content_is_stripped
        content = entry_for("cafe").at_xpath("a:content", ATOM).text

        assert content.start_with?("<p>Short.</p>")
        assert_equal content.strip, content
      end

      def test_entry_summary_is_the_description_in_cdata
        summary = entry_for("review").at_xpath("a:summary", ATOM)

        assert_equal "html", summary["type"]
        assert_predicate summary.children.first, :cdata?
        assert_equal "What happened in 2020.", summary.text
        assert_equal "Short.", entry_for("cafe").at_xpath("a:summary", ATOM).text
      end

      def test_entry_summary_is_omitted_when_the_description_is_empty
        with_site({"_posts/2021-03-01-empty.md" => "---\ntitle: Empty\n---\n"}) do
          entry = atom(loaded_site).at_xpath("/a:feed/a:entry", ATOM)

          assert_equal "Empty", entry.at_xpath("a:title", ATOM).text
          assert_nil entry.at_xpath("a:summary", ATOM)
        end
      end

      def test_entry_summary_is_omitted_for_an_explicitly_empty_description
        with_site({"_posts/2021-03-01-blank.md" => "---\ntitle: Blank\ndescription: \"\"\n---\n\nBody text.\n"}) do
          entry = atom(loaded_site).at_xpath("/a:feed/a:entry", ATOM)

          assert_nil entry.at_xpath("a:summary", ATOM)
          assert_includes entry.at_xpath("a:content", ATOM).text, "Body text."
        end
      end

      def test_entry_titles_are_decoded_and_smartified
        assert_equal "Year — in review", entry_for("review").at_xpath("a:title", ATOM).text
        assert_equal "Year — in review", entry_for("review").at_xpath("a:link", ATOM)["title"]
        assert_equal "html", entry_for("review").at_xpath("a:title", ATOM)["type"]
      end

      def test_entry_titles_get_typographic_punctuation
        with_site({"_posts/2021-03-01-quotes.md" => "---\ntitle: \"Don't stop -- ever...\"\n---\n\nBody.\n"}) do
          title = atom(loaded_site).at_xpath("/a:feed/a:entry/a:title", ATOM).text

          assert_equal "Don’t stop – ever…", title
        end
      end

      def test_feed_title_is_smartified
        with_site({}, config: {title: "Ada's \"notes\""}) do
          assert_equal "Ada’s “notes”", atom(loaded_site).at_xpath("/a:feed/a:title", ATOM).text
        end
      end

      def test_feed_lists_only_the_ten_newest_posts
        posts = (1..12).to_h { |day| ["_posts/2021-04-#{format("%02d", day)}-post-#{day}.md", "---\ntitle: Post #{day}\n---\n\nBody #{day}.\n"] }
        with_site(posts) do
          titles = atom(loaded_site).xpath("/a:feed/a:entry/a:title", ATOM).map(&:text)

          assert_equal (3..12).to_a.reverse.map { |day| "Post #{day}" }, titles
        end
      end

      def test_feed_without_posts_has_no_entries
        with_site do
          feed = atom(loaded_site)

          assert_empty feed.xpath("/a:feed/a:entry", ATOM)
          assert_equal "fixture|site", feed.at_xpath("/a:feed/a:title", ATOM).text
        end
      end

      def test_content_and_summary_containing_a_cdata_terminator_round_trip_exactly
        post = "---\ntitle: Tricky\ndescription: \"one ]]> two ]]> three\"\n---\n\n<div data-x=\"]]>\">body</div>\n"
        with_site({"_posts/2021-03-01-tricky.md" => post}) do
          site = loaded_site
          entry = atom(site).at_xpath("/a:feed/a:entry", ATOM)

          assert_includes site.posts.first.body_html, "]]>"
          assert_equal site.posts.first.body_html.strip, entry.at_xpath("a:content", ATOM).text
          assert_equal "one ]]> two ]]> three", entry.at_xpath("a:summary", ATOM).text
        end
      end

      def test_generate_writes_feed_xml
        Dir.mktmpdir do |dir|
          out, = capture_io { FeedGenerator.new(fixture_site).generate(output_dir: dir) }

          path = File.join(dir, "feed.xml")
          assert_equal "Generated #{path}\n", out
          assert_equal 3, parse_xml(File.read(path)).xpath("/a:feed/a:entry", ATOM).size
        end
      end

      private

      def atom(site)
        parse_xml(FeedGenerator.new(site).build_feed)
      end

      def loaded_site
        Site.new.load_content
      end

      def entry_for(slug)
        atom(fixture_site).at_xpath("/a:feed/a:entry[a:id='https://example.test/#{slug}']", ATOM)
      end

      def terms(entry)
        entry.xpath("a:category", ATOM).map { |category| category["term"] }
      end
    end
  end
end
