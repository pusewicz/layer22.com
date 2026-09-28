# frozen_string_literal: true

require "builder"

module Layer22
  module Generators
    # Writes sitemap.xml with the same URLs the jekyll-sitemap plugin listed.
    class SitemapGenerator
      STATIC_FILES = %w[piotr-usewicz-resume.pdf].freeze

      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        dest = File.join(output_dir, "sitemap.xml")
        File.write(dest, build_sitemap)
        puts "Generated #{dest}"
      end

      # Returns the sitemap as an XML string.
      def build_sitemap
        output = +""
        xml = Builder::XmlMarkup.new(target: output, indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
        xml.urlset(
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" => "http://www.sitemaps.org/schemas/sitemap/0.9 " \
                                  "http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd",
          "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9"
        ) do
          entries.each do |url, lastmod|
            xml.url do
              xml.loc "#{@config.site_url}#{url}"
              xml.lastmod lastmod.xmlschema if lastmod
            end
          end
        end
        output
      end

      private

      def entries
        [
          *@site.posts.map { |post| [post.permalink, post.last_modified_at] },
          *@site.tils.map { |til| [til.permalink, til.last_modified_at] },
          *@site.notes.map { |note| [note.permalink, note.last_modified_at] },
          ["/", @site.posts.last&.date],
          *@site.pages.select { |page| listed?(page) }.map { |page| [page.permalink, page.last_modified_at] },
          *ArchivesGenerator.new(@site).archives.map { |archive| [archive.url, nil] },
          *STATIC_FILES.select { |file| File.exist?(file) }.map { |file| ["/#{file}", Content::LastModified.for(file)] }
        ]
      end

      def listed?(page)
        page.sitemap && page.redirect_to.nil?
      end
    end
  end
end
