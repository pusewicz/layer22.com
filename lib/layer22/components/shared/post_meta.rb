# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # A post's date and reading time, as shown in post listings. Dates from the
      # current year leave the year out.
      class PostMeta < Base
        def initialize(site:, post:)
          super(site:)
          @post = post
        end

        def view_template
          small(class: "post-meta") do
            time(class: "post-date", datetime: @post.date.xmlschema,
                 aria_label: "posted on #{format_date(@post.date, "%A, %e of %B, %Y")}") do
              format_date(@post.date, (@post.date.year == Time.now.year) ? "%b %-d" : "%b %-d %Y")
            end
            whitespace
            span(aria_hidden: "true") { " · " }
            span(class: "word-count", title: "#{@post.word_count} words",
                 aria_label: "#{@post.reading_time} minutes to read this post") do
              reading_time_label(@post.reading_time)
            end
          end
        end
      end
    end
  end
end
