# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class PostArchivePageTest < TestCase
        def year_2021
          fixture_site.posts.last(2).reverse
        end

        def render_archive(**options)
          defaults = {layout: "archive_year", url: "/2021/", heading: "2021", posts: year_2021, date_format: "%b %-d"}
          parse_html(PostArchivePage.new(site: fixture_site, **defaults, **options).call)
        end

        def rows(doc)
          doc.css("main .post-group > div").map { |row| [row.at_css("a").text, row.at_css("a")["href"], row.at_css("span").text] }
        end

        def test_heads_the_page_with_the_heading_and_links_back_to_the_archive
          doc = render_archive

          assert_equal "2021", doc.at_css("main h1").text
          assert_equal "Writing", doc.at_css("main a[href='/archive']").text
        end

        def test_lists_the_posts_in_the_given_order_with_formatted_dates
          assert_equal [["Café notes", "/cafe", "Jun 1"], ["Year — in review", "/review", "Jan 1"]], rows(render_archive)
        end

        def test_formats_dates_as_told
          assert_equal ["Jun 2021", "Jan 2021"], rows(render_archive(date_format: "%b %Y")).map(&:last)
        end

        def test_body_class_names_the_layout_and_the_slugified_title
          assert_equal "layout--archive_year", render_archive.at_css("body")["class"]
          assert_equal "layout--archive_tags café", render_archive(layout: "archive_tags", title: "Café").at_css("body")["class"]
        end

        def test_document_title_names_the_title
          assert_equal "Café · fixture|site", render_archive(title: "Café").at_css("title").text
        end

        def test_seo_uses_the_url
          doc = render_archive(url: "/tags/café/")

          assert_equal "https://example.test/tags/café/", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "website", doc.at_css("meta[property='og:type']")["content"]
        end

        def test_renders_no_rows_without_posts
          assert_empty rows(render_archive(posts: []))
        end

        def test_escapes_the_heading
          heading = %(Tagged: <b>Bold</b> & "quoted")
          doc = render_archive(heading:)

          assert_equal heading, doc.at_css("main h1").text
          assert_nil doc.at_css("main h1 b")
        end

        def test_escapes_post_titles
          title = %(<b>Bold</b> & "quoted")
          doc = render_archive(posts: [fixture_site.posts.first.with(title:)])

          assert_equal [title], doc.css("main .post-group a").map(&:text)
          assert_nil doc.at_css("main .post-group b")
        end
      end
    end
  end
end
