# frozen_string_literal: true

module Layer22
  module Content
    # A Bluesky post a note links to, as `rake note` saved it: the text, its
    # links, when it was posted and the alt text of its image, so the site can
    # show the post without asking Bluesky for it.
    BlueskyPost = Data.define(:handle, :text, :date, :lang, :alt, :facets) do
      # Builds a post from a note's `link.bluesky` front matter; nil when there is none.
      def self.from_front_matter(data)
        return if data.nil?

        new(
          handle: data.fetch("handle"),
          text: data["text"].to_s,
          date: Timestamp.parse(data["date"], source: "link.bluesky.date"),
          lang: data["lang"],
          alt: data["alt"],
          facets: Array(data["facets"]).map do |facet|
            BlueskyPost::Facet.new(from: facet.fetch("from"), to: facet.fetch("to"), url: facet.fetch("url"))
          end
        )
      end

      # Splits the text into runs, each a String and the URL it links to (nil for
      # plain text). Facets that overlap an earlier one, or run past the text, are skipped.
      #
      # @return [Array<Array(String, String)>, Array<Array(String, nil)>]
      def segments
        runs = []
        position = 0
        facets.sort_by(&:from).each do |facet|
          next unless facet.from >= position && facet.from < facet.to && facet.to <= text.length

          runs << [text[position...facet.from], nil] if facet.from > position
          runs << [text[facet.from...facet.to], facet.url]
          position = facet.to
        end
        runs << [text[position..], nil] if position < text.length
        runs
      end
    end

    # A span of a post's text, in characters, that links to +url+.
    BlueskyPost::Facet = Data.define(:from, :to, :url)
  end
end
