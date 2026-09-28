# frozen_string_literal: true

require "builder"

module Layer22
  module Generators
    # Writes the RSS 2.0 feed at /rss.xml, for readers that don't take Atom.
    class RssGenerator
      LIMIT = 10
      DESCRIPTION_LENGTH = 400

      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        dest = File.join(output_dir, "rss.xml")
        File.write(dest, build_feed)
        puts "Generated #{dest}"
      end

      # Returns the RSS feed of the latest posts as an XML string.
      def build_feed
        output = +""
        xml = Builder::XmlMarkup.new(target: output, indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
        xml.rss(
          version: "2.0",
          "xmlns:atom" => "http://www.w3.org/2005/Atom",
          "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
          "xmlns:dc" => "http://purl.org/dc/elements/1.1/"
        ) do
          xml.channel { channel(xml) }
        end
        output
      end

      private

      def channel(xml)
        now = Time.now.rfc822
        editor = "#{@config.email} (#{@config.author_name})"
        xml.title Rendering::Smartify.call(@config.title)
        xml.link "#{@config.site_url}/"
        xml.tag! "atom:link", href: "#{@config.site_url}/rss.xml", rel: "self", type: "application/rss+xml"
        xml.description @config.description
        xml.language "en-US"
        xml.lastBuildDate now
        xml.pubDate now
        xml.managingEditor editor
        xml.webMaster editor
        @site.posts.last(LIMIT).reverse_each { |post| item(xml, post) }
      end

      def item(xml, post)
        url = "#{@config.site_url}#{post.permalink}"
        xml.item do
          xml.title Rendering::Smartify.call(post.title)
          xml.link url
          xml.guid url, isPermaLink: "true"
          xml.pubDate post.date.rfc822
          xml.tag! "dc:creator", @config.author_name
          xml.description Feeds.truncate(Feeds.plain_text(post.body_html), DESCRIPTION_LENGTH)
          xml.tag!("content:encoded") do
            xml.cdata!(Feeds.cdata_safe(Feeds.absolutize(post.body_html.strip, site_url: @config.site_url)))
          end
          post.tags.each { |tag| xml.category tag }
        end
      end
    end
  end
end
