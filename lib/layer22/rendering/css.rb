# frozen_string_literal: true

module Layer22
  module Rendering
    module CSS
      SITE_STYLESHEETS = %w[styles/normalize.css styles/base.css styles/components.css].freeze

      # Returns the stylesheets every page inlines, in cascade order.
      def self.combined_css
        SITE_STYLESHEETS.map { |path| File.read(path) }.join("\n")
      end

      # Returns the Rouge highlighting styles, which only pages with code inline.
      def self.load_syntax
        File.read("styles/syntax.css")
      end
    end
  end
end
