# frozen_string_literal: true

require "date"
require "nokogiri"
require "yaml"

module Layer22
  module Content
    module FrontMatter
      DELIMITER = /^---\s*$/

      def self.read(path)
        File.read(path, encoding: "UTF-8")
      end

      def self.parse(content)
        # Ensure UTF-8 encoding for commonmarker compatibility
        content = content.encode("UTF-8") unless content.encoding.name == "UTF-8"

        lines = content.lines
        return [{}, content] unless lines.first&.match?(DELIMITER)

        end_index = lines[1..].index { |l| l.match?(DELIMITER) }
        return [{}, content] if end_index.nil?

        end_index += 1
        yaml_str = lines[1...end_index].join
        body = lines[(end_index + 1)..].join
        # Ensure body is UTF-8 (ASCII-only strings might have US-ASCII encoding)
        body = body.encode("UTF-8")

        front_matter = YAML.safe_load(yaml_str, permitted_classes: [Date, Time], symbolize_names: false) || {}
        [front_matter, body]
      end

      # Returns a front matter string such as a title as plain text. Jekyll printed
      # titles as raw HTML, so some use entities like "&mdash;".
      def self.text(value)
        Nokogiri::HTML5.fragment(value.to_s).text unless value.nil?
      end

      # Reads a list such as tags the way Jekyll does: the singular key holds one
      # value, the plural key a list or a whitespace-separated string.
      def self.list(front_matter, singular, plural)
        if front_matter.key?(singular)
          Array(front_matter[singular]).compact.map(&:to_s)
        else
          case (value = front_matter[plural])
          when String then value.split
          when Array then value.compact.map(&:to_s)
          else []
          end
        end
      end
    end
  end
end
