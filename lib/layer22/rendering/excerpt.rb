# frozen_string_literal: true

module Layer22
  module Rendering
    # Derives a plain-text summary from Markdown the way Jekyll built post
    # excerpts: the first block before a blank line, rendered and stripped.
    module Excerpt
      LINK_DEFINITION = /^ {0,3}\[[^\]]+\]:[ \t]*\S.*$/

      # Returns the first block of +markdown+ as whitespace-normalised plain text.
      # Like Jekyll, it brings along the document's reference link definitions so
      # reference-style links in that block still resolve.
      def self.from_markdown(markdown)
        first_block = markdown.strip.split(/\n\s*\n/, 2).first.to_s
        definitions = markdown.scan(LINK_DEFINITION)
        html = Markdown.render([first_block, *definitions].join("\n\n"))
        html.gsub(WordCount::MARKUP, "").gsub(/\s+/, " ").strip
      end
    end
  end
end
