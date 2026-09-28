# frozen_string_literal: true

module Layer22
  module Generators
    # Writes the per-tag, per-year, per-month and per-day post archives that the
    # jekyll-archives plugin generated.
    class ArchivesGenerator
      Archive = Data.define(:url, :page)

      def initialize(site)
        @site = site
      end

      def generate(output_dir: "_site")
        archives.each { |archive| site.write_page(archive.url, archive.page.call, output_dir:) }
      end

      # Returns every archive as its URL and the component that renders it.
      def archives
        newest_first = site.posts.reverse
        tag_archives +
          date_archives(newest_first, "%Y/", "archive_year", "%Y") +
          date_archives(newest_first, "%Y/%m/", "archive_month", "%B %Y") +
          date_archives(newest_first, "%Y/%m/%d/", "archive_day", "%B %-d, %Y")
      end

      private

      attr_reader :site

      def date_archives(posts, path_format, layout, heading_format)
        posts.group_by { |post| post.date.strftime(path_format) }.map do |path, period_posts|
          url = "/#{path}"
          page = Components::Pages::PostArchivePage.new(
            site:,
            layout:,
            url:,
            heading: period_posts.first.date.strftime(heading_format),
            posts: period_posts,
            date_format: "%b %-d"
          )
          Archive.new(url:, page:)
        end
      end

      def tag_archives
        site.tags.map do |tag, posts|
          url = "/tags/#{Slug.slugify(tag)}/"
          page = Components::Pages::PostArchivePage.new(
            site:,
            layout: "archive_tags",
            title: tag,
            url:,
            heading: "Tagged: #{tag}",
            posts:,
            date_format: "%b %Y"
          )
          Archive.new(url:, page:)
        end
      end
    end
  end
end
