# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  module Components
    module Pages
      class HomePageTest < TestCase
        def render_home(site = fixture_site)
          parse_html(HomePage.new(site:).call)
        end

        def render_loaded_site(files = {})
          with_site(files) { render_home(Site.new.load_content.load_css) }
        end

        def post_source(title)
          "---\ntitle: #{title.inspect}\n---\n\nBody.\n"
        end

        def recent(doc)
          doc.css("main .h-feed .h-entry").map { |row| [row.at_css("a.u-url").text, row.at_css("a.u-url")["href"]] }
        end

        def meta(doc, key)
          doc.at_css("meta[property='#{key}'], meta[name='#{key}']")&.[]("content")
        end

        def test_titles_the_document_with_the_site_title_and_tagline
          doc = render_home

          assert_equal "fixture|site · A fixture tagline", doc.at_css("title").text
          assert_equal "layout--home home", doc.at_css("body")["class"]
        end

        def test_introduces_the_author_with_an_h_card
          card = render_home.at_css("main .h-card")

          assert_equal "Ada Author", card.at_css(".p-name").text
          assert_equal "Ada Author", card.at_css("img.u-photo")["alt"]
          assert_match %r{\Ahttps://www\.gravatar\.com/avatar/\h+\.jpg}, card.at_css("img.u-photo")["src"]
          assert card.at_css(".p-note").text.length.positive?
        end

        def test_h_card_links_to_the_site_as_the_authors_identity
          link = render_home.at_css("main .h-card a.u-url")

          assert_includes link["class"].split, "u-uid"
          assert_equal "me", link["rel"]
          assert_equal "https://example.test/", link["href"]
        end

        def test_h_card_states_the_authors_location
          card = render_home.at_css("main .h-card")

          assert_equal "Benicàrlo", card.at_css(".p-locality").text
          assert_equal "Spain", card.at_css(".p-country-name").text
        end

        def test_lists_recent_posts_newest_first_with_absolute_links
          assert_equal(
            [["Café notes", "https://example.test/cafe"], ["Year — in review", "https://example.test/review"], ["Hello, World", "https://example.test/hello-world"]],
            recent(render_home)
          )
        end

        def test_lists_only_the_three_most_recent_posts
          files = {
            "_posts/2020-01-01-a.md" => post_source("Oldest"),
            "_posts/2020-02-01-b.md" => post_source("Second"),
            "_posts/2020-03-01-c.md" => post_source("Third"),
            "_posts/2020-04-01-d.md" => post_source("Fourth"),
            "_posts/2020-05-01-e.md" => post_source("Newest")
          }

          assert_equal ["Newest", "Fourth", "Third"], recent(render_loaded_site(files)).map(&:first)
        end

        def test_shows_each_posts_date
          rows = render_home.css("main .h-feed .h-entry")

          assert_equal ["Jun 2021", "Jan 2021", "Mar 2019"], rows.map { |row| row.at_css("time.dt-published").text }
          assert_equal "2021-06-01T00:00:00+02:00", rows.first.at_css("time")["datetime"]
        end

        def test_links_to_the_full_archive
          assert_equal "View all", render_home.at_css("main .h-feed a[href='/archive']").text
        end

        def test_renders_without_posts
          doc = render_loaded_site

          assert_empty recent(doc)
          assert_equal "/archive", doc.at_css("main .h-feed a")["href"]
          assert_nil JSON.parse(doc.at_css("script[type='application/ld+json']").text)["dateModified"]
        end

        def test_escapes_post_titles
          doc = render_loaded_site("_posts/2020-01-01-a.md" => post_source("&lt;b&gt;Bold&lt;/b&gt; &amp; more"))

          assert_equal ["<b>Bold</b> & more"], recent(doc).map(&:first)
          assert_nil doc.at_css("main .h-feed b")
        end

        def test_seo_describes_the_home_page
          doc = render_home
          data = JSON.parse(doc.at_css("script[type='application/ld+json']").text)

          assert_equal "https://example.test/", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "website", meta(doc, "og:type")
          assert_equal "WebSite", data["@type"]
          assert_equal "Ada Author", data["name"]
          assert_equal ["https://github.com/ada", "https://social.example.test/@ada"], data["sameAs"]
        end

        def test_json_ld_is_modified_when_the_newest_post_was_published
          data = JSON.parse(render_home.at_css("script[type='application/ld+json']").text)

          assert_equal "2021-06-01T00:00:00+02:00", data["dateModified"]
        end
      end
    end
  end
end
