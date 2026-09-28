# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  module Components
    module Layouts
      class ApplicationLayoutTest < TestCase
        def render_html(layout: "page", **options)
          ApplicationLayout.new(site: fixture_site, layout:, **options).call { |view| view.p { "Page content" } }
        end

        def render_layout(**)
          parse_html(render_html(**))
        end

        def test_renders_an_html5_document_in_english
          html = render_html(title: "About")

          assert html.start_with?("<!doctype html>")
          assert_equal "en-US", parse_html(html).at_css("html")["lang"]
        end

        def test_declares_charset_and_viewport
          doc = render_layout(title: "About")

          assert_equal "UTF-8", doc.at_css("head meta[charset]")["charset"]
          assert_equal "width=device-width, initial-scale=1", doc.at_css("meta[name=viewport]")["content"]
        end

        def test_home_title_is_the_site_title_and_tagline
          assert_equal "fixture|site · A fixture tagline", render_layout(layout: "home", title: "Home").at_css("title").text
        end

        def test_page_title_is_followed_by_the_site_title
          assert_equal "About · fixture|site", render_layout(title: "About").at_css("title").text
        end

        def test_html_title_replaces_the_title_in_the_document_title
          doc = render_layout(title: "", html_title: "First words of a note…")

          assert_equal "First words of a note… · fixture|site", doc.at_css("title").text
        end

        def test_html_title_defaults_to_the_title
          assert_equal "Today I Learned · fixture|site", render_layout(title: "Today I Learned").at_css("title").text
        end

        def test_untitled_page_has_no_leading_whitespace_in_its_title
          title = render_layout.at_css("title").text

          assert_includes title, "fixture|site"
          refute_match(/\A\s/, title)
        end

        def test_escapes_the_title
          title = %(<b>&"')
          html = render_html(title:)

          assert_equal "#{title} · fixture|site", parse_html(html).at_css("title").text
          refute_includes html.split("</title>").first, "<b>"
        end

        def test_body_classes_name_the_layout_and_the_slugified_title
          assert_equal "layout--page about", render_layout(title: "About").at_css("body")["class"]
          assert_equal "layout--til today-i-learned", render_layout(layout: "til", title: "Today I Learned").at_css("body")["class"]
          assert_equal "layout--home home", render_layout(layout: "home", title: "Home").at_css("body")["class"]
        end

        def test_body_class_slug_keeps_unicode_letters
          assert_equal "layout--archive_tags café", render_layout(layout: "archive_tags", title: "Café").at_css("body")["class"]
        end

        def test_untitled_body_has_only_the_layout_class
          assert_equal "layout--note", render_layout(layout: "note", title: nil).at_css("body")["class"]
        end

        def test_body_enables_instant_page_prefetching_on_viewport
          assert_equal "viewport", render_layout(title: "About").at_css("body")["data-instant-intensity"]
        end

        def test_inlines_the_sites_css_once
          styles = render_layout(title: "About").css("head style")

          assert_equal [fixture_site.css], styles.map(&:text)
          assert_match(/fixture normalize.*fixture base.*fixture components/m, styles.first.text)
        end

        def test_inlines_extra_css_after_the_site_css_unescaped
          css = "/* extra */ a > b { color: red }"
          html = render_html(title: "About", extra_css: css)

          assert_equal [fixture_site.css, css], parse_html(html).css("head style").map(&:text)
          assert_includes html, "a > b { color: red }"
        end

        def test_links_icons_and_manifest
          doc = render_layout(title: "About")

          assert_equal %w[/favicon.ico /favicon.svg /favicon-32x32.png], doc.css("link[rel=icon]").map { |link| link["href"] }
          assert_equal "/site.webmanifest", doc.at_css("link[rel=manifest]")["href"]
        end

        def test_advertises_the_atom_rss_and_notes_feeds
          alternates = render_layout(title: "About").css("link[rel=alternate]").map { |link| link.attributes.transform_values(&:value).slice("type", "href", "title") }

          assert_equal [
            {"type" => "application/atom+xml", "href" => "https://example.test/feed.xml", "title" => "fixture|site"},
            {"type" => "application/rss+xml", "href" => "https://example.test/rss.xml", "title" => "fixture|site"},
            {"type" => "application/rss+xml", "href" => "https://example.test/notes/feed.xml", "title" => "fixture|site · Notes"}
          ], alternates
        end

        def test_loads_web_fonts
          doc = render_layout(title: "About")

          assert_equal "https://fonts.googleapis.com", doc.at_css("link[rel=preconnect]")["href"]
          assert_match %r{\Ahttps://fonts\.googleapis\.com/css2\?family=Barlow\+Condensed}, doc.at_css("link[rel=stylesheet]")["href"]
        end

        def test_renders_seo_tags_for_the_page
          doc = render_layout(title: "About", seo: {url: "/about", description: "About me."})

          assert_equal "https://example.test/about", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "About", doc.at_css("meta[property='og:title']")["content"]
          assert_equal "About me.", doc.at_css("meta[name=description]")["content"]
          assert_equal "website", doc.at_css("meta[property='og:type']")["content"]
          assert_equal "WebPage", JSON.parse(doc.at_css("script[type='application/ld+json']").text)["@type"]
        end

        def test_passes_article_seo_through
          published = Time.new(2021, 3, 5, 8, 0, 0, "+01:00")
          doc = render_layout(title: "Post", seo: {kind: :article, url: "/post", published_at: published})

          assert_equal "article", doc.at_css("meta[property='og:type']")["content"]
          assert_equal "2021-03-05T08:00:00+01:00", doc.at_css("meta[property='article:published_time']")["content"]
        end

        def test_seo_defaults_to_the_home_url
          assert_equal "https://example.test/", render_layout(title: "About").at_css("link[rel=canonical]")["href"]
        end

        def test_rejects_unknown_seo_kinds
          assert_raises(ArgumentError) { render_html(title: "About", seo: {kind: :video}) }
        end

        def test_renders_nav_main_and_footer_in_order
          body = render_layout(title: "About").at_css("body")

          assert_equal %w[nav main footer], body.element_children.map(&:name)
          assert_equal "Page content", body.at_css("main p").text
          assert_equal "/archive", body.at_css("nav a[href='/archive']")["href"]
          assert_match(/Ada Author/, body.at_css("footer").text)
        end
      end
    end
  end
end
