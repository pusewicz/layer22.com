# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # An Instagram post or reel a note links to: its thumbnail, author and
      # caption, all saved in the note, in a card that links to the post on
      # Instagram. Reels are portrait, so their thumbnail is shown whole on black
      # instead of cropped, under a play button.
      class InstagramCard < Base
        # A play button, sized to sit centred on the thumbnail.
        PLAY_BUTTON = <<~SVG.chomp
          <svg aria-hidden="true" width="64" height="64" viewBox="0 0 64 64" class="instagram-card-play"><circle cx="32" cy="32" r="32" fill="rgb(0 0 0 / 55%)"/><path d="M26 20v24l20-12z" fill="#fff"/></svg>
        SVG

        def initialize(site:, link:)
          super(site:)
          @link = link
        end

        def view_template
          a(href: @link.url, class: "link-card instagram-card") do
            if @link.image
              div(class: "instagram-card-media") do
                img(src: @link.image, alt: "", width: @link.image_width, height: @link.image_height, loading: "lazy")
                raw safe(PLAY_BUTTON) if @link.instagram_video?
              end
            end
            div(class: "link-card-body") do
              div(class: "link-card-text") do
                div(class: "display-caption card-source") { source }
                div(class: "link-card-description") { @link.description } if @link.description
              end
            end
          end
        end

        private

        def source
          [@link.site || "Instagram", ("@#{@link.author}" if @link.author)].compact.join(" · ")
        end
      end
    end
  end
end
