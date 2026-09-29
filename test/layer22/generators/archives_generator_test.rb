# frozen_string_literal: true

require "test_helper"

module Layer22
  module Generators
    class ArchivesGeneratorTest < TestCase
      TAG_URLS = %w[/tags/ruby/ /tags/rails/ /tags/café/].freeze
      YEAR_URLS = %w[/2021/ /2019/].freeze
      MONTH_URLS = %w[/2021/06/ /2021/01/ /2019/03/].freeze
      DAY_URLS = %w[/2021/06/01/ /2021/01/01/ /2019/03/14/].freeze

      def test_archives_are_tags_then_years_months_and_days_newest_first
        assert_equal TAG_URLS + YEAR_URLS + MONTH_URLS + DAY_URLS, archives.map(&:url)
      end

      def test_archive_count_is_one_per_tag_year_month_and_day
        assert_equal 11, archives.size
      end

      def test_headings
        headings = archives.to_h { |archive| [archive.url, heading(archive)] }

        assert_equal "Tagged: ruby", headings["/tags/ruby/"]
        assert_equal "Tagged: Café", headings["/tags/café/"]
        assert_equal "2021", headings["/2021/"]
        assert_equal "June 2021", headings["/2021/06/"]
        assert_equal "January 2021", headings["/2021/01/"]
        assert_equal "June 1, 2021", headings["/2021/06/01/"]
        assert_equal "March 14, 2019", headings["/2019/03/14/"]
      end

      def test_year_archive_lists_its_posts_newest_first_with_short_dates
        rows = rows_of("/2021/")

        assert_equal [["Café notes", "/cafe", "Jun 1"], ["Year — in review", "/review", "Jan 1"]], rows
      end

      def test_post_shifted_into_the_next_day_by_the_timezone_is_archived_on_the_local_date
        assert_equal ["/review"], rows_of("/2021/01/01/").map { |_title, href, _date| href }
        assert_equal ["/review"], rows_of("/2021/01/").map { |_title, href, _date| href }
        refute_includes archives.map(&:url), "/2020/"
        refute_includes archives.map(&:url), "/2020/12/31/"
      end

      def test_month_and_day_archives_hold_only_their_own_posts
        assert_equal ["/cafe"], rows_of("/2021/06/").map { |_title, href, _date| href }
        assert_equal ["/hello-world"], rows_of("/2019/03/14/").map { |_title, href, _date| href }
      end

      def test_tag_archive_lists_its_posts_newest_first_with_month_and_year_dates
        rows = rows_of("/tags/ruby/")

        assert_equal [["Café notes", "/cafe", "Jun 2021"], ["Year — in review", "/review", "Jan 2021"], ["Hello, World", "/hello-world", "Mar 2019"]], rows
        assert_equal [["Hello, World", "/hello-world", "Mar 2019"]], rows_of("/tags/rails/")
      end

      def test_tag_archive_url_is_slugified_and_its_title_is_the_tag
        page = html_of("/tags/café/")

        assert_equal "Café · fixture|site", page.at_css("title").text
        assert_includes page.at_css("body")["class"], "layout--archive_tags"
      end

      def test_date_archives_are_named_by_layout
        assert_includes html_of("/2021/").at_css("body")["class"], "layout--archive_year"
        assert_includes html_of("/2021/06/").at_css("body")["class"], "layout--archive_month"
        assert_includes html_of("/2021/06/01/").at_css("body")["class"], "layout--archive_day"
      end

      def test_archive_pages_link_back_to_the_writing_archive
        assert_equal "/archive", html_of("/2021/").at_css("a.section-kicker")["href"]
      end

      def test_generate_writes_every_archive_to_its_output_path
        Dir.mktmpdir do |dir|
          out, = capture_io { ArchivesGenerator.new(fixture_site).generate(output_dir: dir) }

          files = Dir.glob("**/*.html", base: dir).sort
          assert_equal (TAG_URLS + YEAR_URLS + MONTH_URLS + DAY_URLS).map { |url| "#{url.delete_prefix("/")}index.html" }.sort, files
          assert_equal 11, out.lines.size
          assert_equal "June 1, 2021", parse_html(File.read(File.join(dir, "2021/06/01/index.html"))).at_css("h1").text
        end
      end

      def test_site_without_posts_has_no_archives
        with_site do
          site = Site.new.load_content

          assert_empty ArchivesGenerator.new(site).archives
        end
      end

      def test_a_post_with_several_tags_appears_in_each_tag_archive
        with_site({"_posts/2022-02-03-multi.md" => "---\ntitle: Multi\ntags: [one, two words]\n---\n\nBody.\n"}) do
          urls = ArchivesGenerator.new(Site.new.load_content).archives.map(&:url)

          assert_equal %w[/tags/one/ /tags/two-words/ /2022/ /2022/02/ /2022/02/03/], urls
        end
      end

      private

      def archives
        ArchivesGenerator.new(fixture_site).archives
      end

      def html_of(url)
        parse_html(archives.find { |archive| archive.url == url }.page.call)
      end

      def heading(archive)
        parse_html(archive.page.call).at_css("h1").text
      end

      def rows_of(url)
        html_of(url).css(".post-row").map do |row|
          [row.at_css("a").text, row.at_css("a")["href"], row.at_css(".post-row-date").text]
        end
      end
    end
  end
end
