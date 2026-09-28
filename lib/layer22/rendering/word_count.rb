# frozen_string_literal: true

module Layer22
  module Rendering
    # Counts the words of rendered HTML the way Liquid's
    # `strip_html | number_of_words` did for the Jekyll site's reading times.
    module WordCount
      MARKUP = %r{<script.*?</script>|<!--.*?-->|<style.*?</style>|<.*?>}m

      # Returns the number of whitespace-separated words in +html+ once its markup is removed.
      def self.count(html)
        html.gsub(MARKUP, "").split.size
      end
    end
  end
end
