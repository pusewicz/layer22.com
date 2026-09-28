# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  module Components
    module Pages
      class TilPageTest < TestCase
        def til(index)
          fixture_site.tils[index]
        end

        def render_til(til, prev_til: nil, next_til: nil)
          parse_html(TilPage.new(site: fixture_site, til:, prev_til:, next_til:).call)
        end

        def meta(doc, key)
          doc.at_css("meta[property='#{key}'], meta[name='#{key}']")&.[]("content")
        end

        def test_titles_the_document_and_body_after_the_til
          doc = render_til(til(0))

          assert_equal "First TIL · fixture|site", doc.at_css("title").text
          assert_equal "layout--til first-til", doc.at_css("body")["class"]
        end

        def test_heading_is_prefixed_with_til
          assert_equal "TIL: First TIL", render_til(til(0)).at_css("main article h1").text
        end

        def test_escapes_the_title
          title = %(<b>Bold</b> & "quoted")
          doc = render_til(til(0).with(title:))

          assert_equal "TIL: #{title}", doc.at_css("article h1").text
          assert_nil doc.at_css("article h1 b")
        end

        def test_renders_the_body_html_unescaped
          doc = render_til(til(0).with(body_html: "<p>Some <em>emphasis</em> &amp; more</p>"))

          assert_equal "emphasis", doc.at_css("article section p em").text
          assert_equal "Some emphasis & more", doc.at_css("article section p").text
        end

        def test_renders_highlighted_code
          assert render_til(til(2)).at_css("article section div.highlighter-rouge pre code")
        end

        def test_middle_til_links_to_both_neighbours
          doc = render_til(til(1), prev_til: til(0), next_til: til(2))
          prev_link = doc.at_css("article nav a[rel=prev]")
          next_link = doc.at_css("article nav a[rel=next]")

          assert_equal "/til/2021/03/05/first-til/", prev_link["href"]
          assert_equal "← TIL: First TIL", prev_link.text
          assert_equal "/til/2022/01/10/third-til/", next_link["href"]
          assert_equal "TIL: Third TIL →", next_link.text
        end

        def test_first_til_has_no_older_link
          doc = render_til(til(0), next_til: til(1))

          assert_nil doc.at_css("article nav a[rel=prev]")
          assert_equal "/til/2021/03/20/second-til/", doc.at_css("article nav a[rel=next]")["href"]
        end

        def test_last_til_has_no_newer_link
          doc = render_til(til(2), prev_til: til(1))

          assert_nil doc.at_css("article nav a[rel=next]")
          assert_equal "/til/2021/03/20/second-til/", doc.at_css("article nav a[rel=prev]")["href"]
        end

        def test_a_single_til_has_no_neighbour_links
          assert_empty render_til(til(0)).css("article nav a")
        end

        def test_escapes_neighbour_titles
          title = %(<b>Bold</b> & "quoted")
          doc = render_til(til(1), prev_til: til(0).with(title:), next_til: til(2).with(title:))

          assert_equal ["← TIL: #{title}", "TIL: #{title} →"], doc.css("article nav a").map(&:text)
          assert_nil doc.at_css("article nav b")
        end

        def test_inlines_the_syntax_css_after_the_site_css
          assert_equal [fixture_site.css, fixture_site.syntax_css], render_til(til(0)).css("head style").map(&:text)
        end

        def test_seo_describes_the_til_as_an_article
          doc = render_til(til(1))

          assert_equal "https://example.test/til/2021/03/20/second-til/", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "article", meta(doc, "og:type")
          assert_equal "Second TIL", meta(doc, "og:title")
          assert_equal "Learned something else.", meta(doc, "description")
          assert_equal "2021-03-20T18:45:00+01:00", meta(doc, "article:published_time")
          assert_equal "2021-03-21T08:00:00+01:00", meta(doc, "article:modified_time")
          assert_equal "BlogPosting", JSON.parse(doc.at_css("script[type='application/ld+json']").text)["@type"]
        end
      end
    end
  end
end
