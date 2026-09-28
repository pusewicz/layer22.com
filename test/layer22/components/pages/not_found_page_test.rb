# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class NotFoundPageTest < TestCase
        def render_page
          parse_html(NotFoundPage.new(site: fixture_site).call)
        end

        def test_says_the_page_was_not_found
          content = render_page.at_css("main")

          assert_equal "404", content.at_css("h1").text
          assert_includes content.text, "Page not found :("
          assert_includes content.text, "The requested page could not be found."
        end

        def test_links_home
          link = render_page.at_css("main a")

          assert_equal "/", link["href"]
          assert_equal "Go Back Home", link.text
        end

        def test_has_the_default_layout_and_no_title_class
          assert_equal "layout--default", render_page.at_css("body")["class"]
        end

        def test_document_title_is_just_the_site_title
          title = render_page.at_css("title").text

          assert_includes title, "fixture|site"
          refute_match(/\A\s/, title)
        end

        def test_canonical_url_is_the_404_page
          doc = render_page

          assert_equal "https://example.test/404.html", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "https://example.test/404.html", doc.at_css("meta[property='og:url']")["content"]
        end

        def test_styles_the_page_inline
          style = render_page.at_css("main style")

          assert_equal "screen", style["media"]
          assert_includes style.text, ".container {"
          assert_includes style.text, "text-align: center;"
        end

        def test_renders_nav_and_footer
          body = render_page.at_css("body")

          assert_equal %w[nav main footer], body.element_children.map(&:name)
        end
      end
    end
  end
end
