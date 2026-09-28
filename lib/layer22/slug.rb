# frozen_string_literal: true

module Layer22
  # Slugifies strings exactly like Jekyll's default `slugify` mode, which the
  # site's tag URLs, anchors and body classes were built with.
  module Slug
    SEPARATORS = /[^\p{M}\p{L}\p{Nd}]+/

    # Returns +string+ lowercased, with each run of characters other than letters,
    # marks and digits turned into one hyphen; "" for nil.
    def self.slugify(string)
      string.to_s.gsub(SEPARATORS, "-").gsub(/\A-|-\z/, "").downcase
    end
  end
end
