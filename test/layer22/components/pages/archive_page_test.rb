# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class ArchivePageTest < TestCase
        ARCHIVE_PAGE = <<~MD
          ---
          layout: archive
          title: Archive
          permalink: /archive
          ---
        MD

        def render_archive(site = fixture_site)
          page = site.pages.find { |candidate| candidate.permalink == "/archive" }
          parse_html(ArchivePage.new(site:, page:).call)
        end

        def render_loaded_site(files)
          with_site(files) { render_archive(Site.new.load_content.load_css) }
        end

        def post_source(title)
          "---\ntitle: #{title.inspect}\n---\n\nBody.\n"
        end

        def groups(doc)
          doc.css("main .post-group").to_h do |group|
            [group.at_css("h2").text, group.css("a").map { |a| [a.text, a["href"]] }]
          end
        end

        def test_titles_the_document_and_body_after_the_page
          doc = render_archive

          assert_equal "Archive · fixture|site", doc.at_css("title").text
          assert_equal "layout--archive archive", doc.at_css("body")["class"]
        end

        def test_heads_the_page_writing
          assert_equal "Writing", render_archive.at_css("main h1").text
        end

        def test_groups_posts_by_year_newest_year_first
          assert_equal %w[2021 2019], groups(render_archive).keys
        end

        def test_lists_each_years_posts_newest_first_with_absolute_links
          assert_equal(
            {
              "2021" => [["Café notes", "https://example.test/cafe"], ["Year — in review", "https://example.test/review"]],
              "2019" => [["Hello, World", "https://example.test/hello-world"]]
            },
            groups(render_archive)
          )
        end

        def test_files_a_post_by_its_local_year
          review = fixture_site.posts[1]
          groups = groups(render_archive)

          assert_equal 2020, review.date.getutc.year
          assert_includes groups["2021"].map(&:last), "https://example.test/review"
          assert_nil groups["2020"]
        end

        def test_marks_up_each_post_as_an_h_entry_with_its_date
          rows = render_archive.css("main .h-feed .h-entry")

          assert_equal 3, rows.size
          assert_equal %w[2021-06-01T00:00:00+02:00 2021-01-01T00:30:00+01:00 2019-03-14T00:00:00+01:00],
            rows.map { |row| row.at_css("time.dt-published")["datetime"] }
          assert_equal ["Jun 2021", "Jan 2021", "Mar 2019"], rows.map { |row| row.at_css("time").text }
          assert(rows.all? { |row| row.at_css("a.u-url") })
        end

        def test_renders_no_years_without_posts
          doc = render_loaded_site("_pages/archive.md" => ARCHIVE_PAGE)

          assert_empty doc.css("h2")
          assert_equal "Writing", doc.at_css("h1").text
        end

        def test_escapes_post_titles
          doc = render_loaded_site(
            "_pages/archive.md" => ARCHIVE_PAGE,
            "_posts/2021-03-05-tagged.md" => post_source("&lt;b&gt;Bold&lt;/b&gt; &amp; more")
          )

          assert_equal ["<b>Bold</b> & more"], doc.css("main .h-entry a").map(&:text)
          assert_nil doc.at_css("main .h-entry b")
        end

        def test_seo_describes_the_page
          doc = render_archive

          assert_equal "https://example.test/archive", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "website", doc.at_css("meta[property='og:type']")["content"]
        end
      end
    end
  end
end
