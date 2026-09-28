# frozen_string_literal: true

require "commonmarker"
require "nokogiri"

module Layer22
  module Rendering
    # Applies typographic punctuation to plain text, like Liquid's `smartify`
    # filter did for feed titles: curly quotes, en and em dashes, ellipses.
    module Smartify
      # Returns +text+ with straight quotes, "--", "---" and "..." made typographic.
      def self.call(text)
        html = Commonmarker.to_html(text.to_s, options: {parse: {smart: true}})
        Nokogiri::HTML5.fragment(html).text.strip
      end
    end
  end
end
