# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # A Bluesky post a note links to: its picture, author, text and date, all
      # saved in the note. The text keeps the links, mentions and hashtags of the
      # post; everything else links to the post on Bluesky.
      class BlueskyCard < Base
        def initialize(site:, link:)
          super(site:)
          @link = link
          @post = link.bluesky
        end

        def view_template
          div(class: "bluesky-card") do
            if @link.image
              a(href: @link.url, class: "bluesky-card-media", **media_link_attributes) do
                img(src: @link.image, alt: @post.alt.to_s, width: @link.image_width, height: @link.image_height, loading: "lazy")
              end
            end
            div(class: "bluesky-card-body") do
              a(href: @link.url, class: "display-caption card-source bluesky-card-source") { source }
              div(class: "bluesky-card-text", lang: @post.lang) { text } unless @post.text.empty?
              posted if @post.date
            end
          end
        end

        private

        def source
          [@link.site || "Bluesky", @link.author, "@#{@post.handle}"].compact.join(" · ")
        end

        def text
          @post.segments.each do |run, url|
            url ? a(href: url) { run } : plain(run)
          end
        end

        def posted
          a(href: @link.url, class: "display-caption bluesky-card-date") do
            time(datetime: @post.date.xmlschema) { format_date(@post.date, "%b %-d, %Y") }
          end
        end

        def media_link_attributes
          @post.alt.to_s.empty? ? {aria_hidden: "true", tabindex: "-1"} : {}
        end
      end
    end
  end
end
