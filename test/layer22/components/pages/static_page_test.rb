# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class StaticPageTest < TestCase
        def page(permalink)
          fixture_site.pages.find { |candidate| candidate.permalink == permalink }
        end

        def render_page(permalink)
          parse_html(StaticPage.new(site: fixture_site, page: page(permalink)).call)
        end

        def body_children(doc)
          doc.at_css("main article > div").element_children
        end

        def test_titles_the_document_and_body_after_the_page
          doc = render_page("/about")

          assert_equal "About · fixture|site", doc.at_css("title").text
          assert_equal "layout--page about", doc.at_css("body")["class"]
        end

        def test_renders_the_pages_markdown_body
          content = render_page("/about").at_css("main article")

          assert_equal "About", content.at_css("h1").text
          assert_equal "Some words about the fixture.", content.at_css("p").text
        end

        def test_renders_html_pages_unescaped
          paragraph = render_page("/colophon").at_css("main article p.raw")

          assert_equal "Hand-written HTML.", paragraph.text
        end

        def test_a_page_without_a_listing_has_nothing_after_its_body
          assert_equal %w[h1 p], body_children(render_page("/about")).map(&:name)
        end

        def test_seo_describes_the_page
          doc = render_page("/about")

          assert_equal "https://example.test/about", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "About the fixture.", doc.at_css("meta[name=description]")["content"]
          assert_equal "website", doc.at_css("meta[property='og:type']")["content"]
        end

        def test_seo_falls_back_to_the_site_description
          assert_equal "Fixture description", render_page("/colophon").at_css("meta[name=description]")["content"]
        end

        def test_tils_listing_follows_the_body
          children = body_children(render_page("/til"))

          assert_equal %w[h1 ul], children.map(&:name)
        end

        def test_tils_listing_lists_every_til_in_site_order
          list = render_page("/til").at_css("main article ul")

          assert_equal fixture_site.tils.map(&:permalink), list.css("li p > a").map { |a| a["href"] }
          assert_equal ["First TIL", "Second TIL", "Third TIL"], list.css("li p > a").map(&:text)
          assert(list.css("li").all? { |li| li.at_css("time[datetime]") })
        end

        def test_tags_listing_follows_the_body
          doc = render_page("/tags")

          assert_equal %w[h1 nav h2 ul h2 ul h2 ul], body_children(doc).map(&:name)
          assert_equal "Tags", doc.at_css("main article nav")["aria-label"]
          assert_equal %w[ruby rails café], doc.css("main article h2").map { |h2| h2["id"] }
        end

        def test_categories_listing_follows_the_body
          doc = render_page("/categories")

          assert_equal %w[h1 nav h2 ul h2 ul], body_children(doc).map(&:name)
          assert_equal "Categories", doc.at_css("main article nav")["aria-label"]
          assert_equal %w[code life], doc.css("main article h2").map { |h2| h2["id"] }
        end

        def test_a_listing_names_posts_from_the_site
          list = render_page("/categories").at_css("main article ul")

          assert_equal ["Hello, World"], list.css("li p > a").map(&:text)
        end

        def test_unknown_listing_raises_naming_the_file
          files = {"_pages/bad.md" => "---\ntitle: Bad\npermalink: /bad\nlisting: bogus\n---\nBody\n"}

          with_site(files) do
            bad = Site.new.load_content.pages.first
            error = assert_raises(ArgumentError) { StaticPage.new(site: Site.new, page: bad) }

            assert_equal %(_pages/bad.md: unknown listing "bogus"), error.message
          end
        end

        def test_a_nil_listing_is_accepted
          files = {"_pages/plain.md" => "---\ntitle: Plain\npermalink: /plain\n---\nBody\n"}

          with_site(files) do
            site = Site.new.load_content.load_css
            doc = parse_html(StaticPage.new(site:, page: site.pages.first).call)

            assert_equal %w[p], doc.at_css("main article > div").element_children.map(&:name)
          end
        end

        def test_escapes_the_title_but_not_the_body
          files = {"_pages/odd.html" => "---\ntitle: \"&lt;b&gt;Odd&lt;/b&gt;\"\npermalink: /odd\n---\n<p>Raw <em>html</em></p>\n"}

          with_site(files) do
            site = Site.new.load_content.load_css
            doc = parse_html(StaticPage.new(site:, page: site.pages.first).call)

            assert_equal "<b>Odd</b> · fixture|site", doc.at_css("title").text
            assert_equal "html", doc.at_css("main article p em").text
          end
        end
      end
    end
  end
end
