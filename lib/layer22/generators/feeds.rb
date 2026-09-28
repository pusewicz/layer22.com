# frozen_string_literal: true

require "nokogiri"

module Layer22
  module Generators
    # Text helpers shared by the Atom and RSS feeds.
    module Feeds
      # Returns +text+ safe to wrap in CDATA, splitting any "]]>" it contains.
      def self.cdata_safe(text)
        text.gsub("]]>", "]]]]><![CDATA[>")
      end

      # Returns +html+ with root-relative links and images made absolute, so feed
      # readers resolve them against the site rather than themselves.
      def self.absolutize(html, site_url:)
        html.gsub('href="/', %(href="#{site_url}/)).gsub('src="/', %(src="#{site_url}/))
      end

      BLOCK_ELEMENTS = %w[
        address article aside blockquote br dd div dl dt figcaption figure footer h1 h2 h3 h4 h5 h6
        header hr li main nav ol p pre section table td th tr ul
      ].to_set.freeze
      SKIPPED_ELEMENTS = %w[script style template].to_set.freeze

      # Returns the text of +html+ as a reader sees it: entities decoded, block
      # elements separating words, whitespace collapsed.
      def self.plain_text(html)
        collect_text(Nokogiri::HTML5.fragment(html), +"").gsub(/\s+/, " ").strip
      end

      def self.collect_text(node, text)
        node.children.each do |child|
          if child.text?
            text << child.text
          elsif child.element? && !SKIPPED_ELEMENTS.include?(child.name)
            block = BLOCK_ELEMENTS.include?(child.name)
            text << " " if block
            collect_text(child, text)
            text << " " if block
          end
        end
        text
      end

      private_class_method :collect_text

      # Shortens +text+ to +length+ characters, ending in "...", like Liquid's truncate.
      def self.truncate(text, length)
        (text.length > length) ? "#{text[0, length - 3]}..." : text
      end
    end
  end
end
