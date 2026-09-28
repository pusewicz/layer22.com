# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class RedirectPageTest < TestCase
        TARGET = "https://elsewhere.test/landing"

        def render_html(to: TARGET)
          RedirectPage.new(to:).call
        end

        def render_page(to: TARGET)
          parse_html(render_html(to:))
        end

        def test_renders_an_html5_document
          html = render_html

          assert html.start_with?("<!doctype html>")
          assert_equal "en-US", parse_html(html).at_css("html")["lang"]
        end

        def test_canonical_link_points_at_the_target
          assert_equal TARGET, render_page.at_css("link[rel=canonical]")["href"]
        end

        def test_meta_refresh_redirects_immediately
          assert_equal "0; url=#{TARGET}", render_page.at_css("meta[http-equiv=refresh]")["content"]
        end

        def test_script_redirects_the_browser
          assert_equal %(location="#{TARGET}"), render_page.at_css("script").text
        end

        def test_is_not_indexed
          assert_equal "noindex", render_page.at_css("meta[name=robots]")["content"]
        end

        def test_titles_the_page_as_a_redirect
          doc = render_page

          assert_equal "Redirecting…", doc.at_css("title").text
          assert_equal "Redirecting…", doc.at_css("h1").text
        end

        def test_offers_a_link_to_humans
          link = render_page.at_css("body a")

          assert_equal TARGET, link["href"]
          assert_equal "Click here if you are not redirected.", link.text
        end

        def test_escapes_the_target_in_the_meta_refresh
          to = %(https://elsewhere.test/a?x=1&y="2")
          html = render_html(to:)

          assert_includes html, %(content="0; url=https://elsewhere.test/a?x=1&amp;y=&quot;2&quot;")
          assert_equal "0; url=#{to}", parse_html(html).at_css("meta[http-equiv=refresh]")["content"]
        end

        def test_escapes_the_target_in_attributes
          to = %(https://elsewhere.test/a?x=1&y="2")
          doc = render_page(to:)

          assert_equal to, doc.at_css("link[rel=canonical]")["href"]
          assert_equal to, doc.at_css("body a")["href"]
        end

        def test_json_escapes_the_target_in_the_script
          to = %(https://elsewhere.test/a?x=1&y="2")

          assert_equal %(location="https://elsewhere.test/a?x=1&y=\\"2\\""), render_page(to:).at_css("script").text
        end

        def test_a_target_cannot_close_the_script_or_the_meta_tag
          to = %(https://elsewhere.test/"></script><script>alert(1)</script>)
          html = render_html(to:)
          doc = parse_html(html)

          assert_equal 1, doc.css("script").size
          assert_includes doc.at_css("script").text, "<\\/script>"
          assert_equal "0; url=#{to}", doc.at_css("meta[http-equiv=refresh]")["content"]
        end
      end
    end
  end
end
