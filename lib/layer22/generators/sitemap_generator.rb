# frozen_string_literal: true

require "builder"

module Layer22
  module Generators
    class SitemapGenerator
      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        xml = build_sitemap
        dest = File.join(output_dir, "sitemap.xml")
        File.write(dest, xml)
        puts "Generated #{dest}"
      end

      private

      def build_sitemap
        output = +""
        xml = Builder::XmlMarkup.new(target: output, indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
        xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
          # Home
          xml.url do
            xml.loc @config.site_url
            xml.changefreq "weekly"
            xml.priority "1.0"
          end

          # Posts
          @site.posts.each do |post|
            xml.url do
              xml.loc "#{@config.site_url}#{post.permalink}"
              xml.lastmod post.last_modified_at.strftime("%Y-%m-%d")
              xml.changefreq "monthly"
              xml.priority "0.8"
            end
          end

          # TILs
          @site.tils.each do |til|
            xml.url do
              xml.loc "#{@config.site_url}#{til.permalink}"
              xml.lastmod til.date.strftime("%Y-%m-%d")
              xml.changefreq "monthly"
              xml.priority "0.6"
            end
          end

          # Pages
          @site.pages.each do |page|
            next unless page.permalink
            xml.url do
              xml.loc "#{@config.site_url}#{page.permalink}"
              xml.changefreq "monthly"
              xml.priority "0.5"
            end
          end
        end
        output
      end
    end
  end
end
