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

      def write_page(path, html)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, html)
        puts "Generated #{path}"
      end

      def generate_all_archive(output_dir)
        posts = site.posts.sort_by(&:date).reverse
        html = Components::Pages::ArchivePage.new(
          site:,
          title: "Archive",
          posts:,
          url: "/archive"
        ).call
        write_page("#{output_dir}/archive/index.html", html)
      end

      def generate_year_archives(output_dir)
        site.posts.group_by { |p| p.date.year }.each do |year, posts|
          html = Components::Pages::ArchivePage.new(
            site:,
            title: year.to_s,
            posts: posts.sort_by(&:date).reverse,
            url: "/#{year}/"
          ).call
          write_page("#{output_dir}/#{year}/index.html", html)
        end
      end

      def generate_month_archives(output_dir)
        site.posts.group_by { |p| [p.date.year, p.date.month] }.each do |(year, month), posts|
          month_str = format("%02d", month)
          html = Components::Pages::ArchivePage.new(
            site:,
            title: "#{year}/#{month_str}",
            posts: posts.sort_by(&:date).reverse,
            url: "/#{year}/#{month_str}/"
          ).call
          write_page("#{output_dir}/#{year}/#{month_str}/index.html", html)
        end
      end

      def generate_day_archives(output_dir)
        site.posts.group_by { |p| [p.date.year, p.date.month, p.date.day] }.each do |(year, month, day), posts|
          month_str = format("%02d", month)
          day_str = format("%02d", day)
          html = Components::Pages::ArchivePage.new(
            site:,
            title: "#{year}/#{month_str}/#{day_str}",
            posts: posts.sort_by(&:date).reverse,
            url: "/#{year}/#{month_str}/#{day_str}/"
          ).call
          write_page("#{output_dir}/#{year}/#{month_str}/#{day_str}/index.html", html)
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
          write_page("#{output_dir}/tags/#{slug}/index.html", html)
        end
      end

      def generate_tags_index(output_dir)
        tags = Hash.new { |h, k| h[k] = [] }
        site.posts.each { |p| p.tags.each { |tag| tags[tag] << p } }
        sorted_tags = tags.sort_by { |tag, posts| [-posts.size, tag] }

        html = Components::Pages::TagsIndexPage.new(site:, tags: sorted_tags).call
        write_page("#{output_dir}/tags/index.html", html)
      end

      def generate_til_listing(output_dir)
        tils = site.tils.sort_by(&:date).reverse
        html = Components::Pages::ArchivePage.new(
          site:,
          title: "Today I Learned",
          posts: tils,
          url: "/til"
        ).call
        write_page("#{output_dir}/til/index.html", html)
      end
    end
  end
end
