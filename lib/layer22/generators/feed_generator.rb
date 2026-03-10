# frozen_string_literal: true

require "builder"
require "cgi"

module Layer22
  module Generators
    class FeedGenerator
      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        posts = @site.posts.sort_by(&:date).reverse.first(20)
        xml = build_feed(posts)
        dest = File.join(output_dir, "feed.xml")
        File.write(dest, xml)
        puts "Generated #{dest}"
      end

      private

      def build_feed(posts)
        output = +""
        xml = Builder::XmlMarkup.new(target: output, indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
        xml.feed(xmlns: "http://www.w3.org/2005/Atom") do
          xml.title @config.title
          xml.subtitle @config.tagline
          xml.link href: "#{@config.site_url}/feed.xml", rel: "self"
          xml.link href: @config.site_url
          xml.id @config.site_url
          xml.updated posts.first&.date&.strftime("%Y-%m-%dT00:00:00Z") || Time.now.utc.iso8601
          xml.author do
            xml.name @config.author_name
            xml.email @config.email
          end

          posts.each do |post|
            xml.entry do
              xml.title post.title
              xml.link rel: "alternate", href: "#{@config.site_url}#{post.permalink}"
              xml.id "#{@config.site_url}#{post.permalink}"
              xml.published post.date.strftime("%Y-%m-%dT00:00:00Z")
              xml.updated post.last_modified_at.strftime("%Y-%m-%dT00:00:00Z")
              xml.author { xml.name @config.author_name }
              xml.content(post.body_html, type: "html")
              post.tags.each { |tag| xml.category(term: tag) }
            end
          end
        end
        output
      end
    end
  end
end
