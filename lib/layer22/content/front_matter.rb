# frozen_string_literal: true

require "yaml"

module Layer22
  module Content
    module FrontMatter
      DELIMITER = /^---\s*$/.freeze

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
    end
  end
end
