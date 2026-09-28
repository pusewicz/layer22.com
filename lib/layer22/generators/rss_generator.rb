# frozen_string_literal: true

require "builder"

module Layer22
  module Generators
    # Writes an RSS 2.0 feed: the posts at /rss.xml, for readers that don't take
    # Atom, and the notes at /notes/feed.xml.
    class RssGenerator
      LIMIT = 10
      DESCRIPTION_LENGTH = 400

      # A feed: where it lives, how it describes itself, and its items, oldest first.
      Channel = Data.define(:path, :title, :description, :link, :items)

      # Returns the site's RSS channels.
      def self.channels(site)
        config = site.config
        [
          Channel.new(path: "/rss.xml", title: config.title, description: config.description, link: "/",
                      items: site.posts),
          Channel.new(path: "/notes/feed.xml", title: "#{config.title} · Notes",
                      description: "Short notes and links from #{config.author_name}", link: "/notes/", items: site.notes)
        ]
      end

      def initialize(site, channel)
        @site = site
        @config = site.config
        @channel = channel
      end

      def generate(output_dir: "_site")
        @site.write_page(@channel.path, build_feed, output_dir:)
      end

      # Returns the feed as an XML string.
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
        xml.title Rendering::Smartify.call(@channel.title)
        xml.link "#{@config.site_url}#{@channel.link}"
        xml.tag! "atom:link", href: "#{@config.site_url}#{@channel.path}", rel: "self", type: "application/rss+xml"
        xml.description @channel.description
        xml.language "en-US"
        xml.lastBuildDate now
        xml.pubDate now
        xml.managingEditor editor
        xml.webMaster editor
        @channel.items.last(LIMIT).reverse_each { |item| item(xml, item) }
      end

      # Writes one item. Untitled items (notes) leave out <title>, and an item
      # with a link gets its link card (or YouTube card) appended to its content.
      def item(xml, item)
        url = "#{@config.site_url}#{item.permalink}"
        html = content_html(item)
        xml.item do
          xml.title Rendering::Smartify.call(item.title) unless item.title.to_s.empty?
          xml.link url
          xml.guid url, isPermaLink: "true"
          xml.pubDate item.date.rfc822
          xml.tag! "dc:creator", @config.author_name
          xml.description Feeds.truncate(Feeds.plain_text(html), DESCRIPTION_LENGTH)
          xml.tag!("content:encoded") do
            xml.cdata!(Feeds.cdata_safe(Feeds.absolutize(html, site_url: @config.site_url)))
          end
          item.tags.each { |tag| xml.category tag }
        end
      end

      def content_html(item)
        html = item.body_html.strip
        link = item.link if item.respond_to?(:link)
        return html unless link

        card = if link.youtube
          Components::Shared::YoutubeCard.new(site: @site, link:, feed: true)
        else
          Components::Shared::LinkCard.new(site: @site, link:)
        end
        html + card.call
      end
    end
  end
end
