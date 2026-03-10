# frozen_string_literal: true

require "phlex"

module Layer22
  module Components
    class Base < Phlex::HTML
      def initialize(site:)
        @site = site
      end

      private

      attr_reader :site

      def config
        site.config
      end

      def format_date(date, fmt = "%B %-d, %Y")
        date&.strftime(fmt)
      end

      def reading_time_label(minutes)
        "#{minutes} min read"
      end

      def tag_url(tag)
        "/tags/#{tag.downcase.gsub(/\s+/, "-")}/"
      end
    end
  end
end
