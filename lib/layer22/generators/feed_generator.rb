# frozen_string_literal: true

require "builder"

module Layer22
  module Generators
    # Writes the Atom feed at /feed.xml in the shape the jekyll-feed plugin produced.
    class FeedGenerator
      LIMIT = 10

      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        dest = File.join(output_dir, "feed.xml")
        File.write(dest, build_feed)
        puts "Generated #{dest}"
      end

      # Returns the Atom feed of the latest posts as an XML string.
      def build_feed
        output = +""
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct! :xml, version: "1.0", encoding: "utf-8"
        xml.feed(xmlns: "http://www.w3.org/2005/Atom") do
          xml.link href: "#{@config.site_url}/feed.xml", rel: "self", type: "application/atom+xml"
          xml.link href: "#{@config.site_url}/", rel: "alternate", type: "text/html"
          xml.updated Time.now.xmlschema
          xml.id "#{@config.site_url}/feed.xml"
          xml.title Rendering::Smartify.call(@config.title), type: "html"
          xml.subtitle @config.description
          author(xml)
          @site.posts.last(LIMIT).reverse_each { |post| entry(xml, post) }
        end
        output
      end

      private

      def entry(xml, post)
        url = "#{@config.site_url}#{post.permalink}"
        title = Rendering::Smartify.call(post.title)
        xml.entry do
          xml.title title, type: "html"
          xml.link href: url, rel: "alternate", type: "text/html", title: title
          xml.published post.date.xmlschema
          xml.updated post.last_modified_at.xmlschema
          xml.id url
          xml.content(type: "html", "xml:base" => url) { xml.cdata!(Feeds.cdata_safe(post.body_html.strip)) }
          author(xml)
          (post.categories + post.tags).each { |term| xml.category term: }
          xml.summary(type: "html") { xml.cdata!(Feeds.cdata_safe(post.description)) } unless post.description.empty?
        end
      end

      def author(xml)
        xml.author do
          xml.name @config.author_name
          xml.email @config.email
        end
      end
    end
  end
end
