# frozen_string_literal: true

module Layer22
  module Generators
    class ArchivesGenerator
      def initialize(site)
        @site = site
      end

      def generate(output_dir: "_site")
        generate_year_archives(output_dir)
        generate_month_archives(output_dir)
        generate_day_archives(output_dir)
        generate_tag_archives(output_dir)
        generate_tags_index(output_dir)
        generate_all_archive(output_dir)
        generate_til_listing(output_dir)
      end

      private

      def site
        @site
      end

      def generate_all_archive(output_dir)
        posts = site.posts.sort_by(&:date).reverse
        html = Components::Pages::ArchivePage.new(
          site:,
          title: "Archive",
          posts:,
          url: "/archive"
        ).call
        site.write_page("/archive", html, output_dir:)
      end

      def generate_year_archives(output_dir)
        site.posts.group_by { |p| p.date.year }.each do |year, posts|
          url = "/#{year}/"
          html = Components::Pages::ArchivePage.new(
            site:,
            title: year.to_s,
            posts: posts.sort_by(&:date).reverse,
            url:
          ).call
          site.write_page(url, html, output_dir:)
        end
      end

      def generate_month_archives(output_dir)
        site.posts.group_by { |p| [p.date.year, p.date.month] }.each do |(year, month), posts|
          month_str = format("%02d", month)
          url = "/#{year}/#{month_str}/"
          html = Components::Pages::ArchivePage.new(
            site:,
            title: "#{year}/#{month_str}",
            posts: posts.sort_by(&:date).reverse,
            url:
          ).call
          site.write_page(url, html, output_dir:)
        end
      end

      def generate_day_archives(output_dir)
        site.posts.group_by { |p| [p.date.year, p.date.month, p.date.day] }.each do |(year, month, day), posts|
          month_str = format("%02d", month)
          day_str = format("%02d", day)
          url = "/#{year}/#{month_str}/#{day_str}/"
          html = Components::Pages::ArchivePage.new(
            site:,
            title: "#{year}/#{month_str}/#{day_str}",
            posts: posts.sort_by(&:date).reverse,
            url:
          ).call
          site.write_page(url, html, output_dir:)
        end
      end

      def generate_tag_archives(output_dir)
        tags = Hash.new { |h, k| h[k] = [] }
        site.posts.each do |post|
          post.tags.each { |tag| tags[tag] << post }
        end

        tags.each do |tag, posts|
          slug = tag.downcase.gsub(/\s+/, "-")
          html = Components::Pages::TagPage.new(
            site:,
            tag:,
            posts: posts.sort_by(&:date).reverse
          ).call
          site.write_page("/tags/#{slug}/", html, output_dir:)
        end
      end

      def generate_tags_index(output_dir)
        tags = Hash.new { |h, k| h[k] = [] }
        site.posts.each { |p| p.tags.each { |tag| tags[tag] << p } }
        sorted_tags = tags.sort_by { |tag, posts| [-posts.size, tag] }

        html = Components::Pages::TagsIndexPage.new(site:, tags: sorted_tags).call
        site.write_page("/tags", html, output_dir:)
      end

      def generate_til_listing(output_dir)
        tils = site.tils.sort_by(&:date).reverse
        html = Components::Pages::ArchivePage.new(
          site:,
          title: "Today I Learned",
          posts: tils,
          url: "/til"
        ).call
        site.write_page("/til", html, output_dir:)
      end
    end
  end
end
