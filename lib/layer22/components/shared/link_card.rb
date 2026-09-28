# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # A preview of the page a note links to. Images wider than 5:4 run full
      # width above the text, cropped to 16:9 (which also trims YouTube
      # letterboxing); squarer ones (avatars, logos) sit beside it as a thumbnail.
      class LinkCard < Base
        def initialize(site:, link:)
          super(site:)
          @link = link
        end

        def view_template
          a(href: @link.url, class: "link-card") do
            if wide_image?
              img(src: @link.image, alt: "", width: @link.image_width.to_s, height: @link.image_height.to_s,
                  class: "link-card-image", loading: "lazy")
            end
            div(class: "link-card-body") do
              div(class: "link-card-text") do
                div(class: "display-caption card-source") { source }
                div(class: "card-title") { @link.title || @link.url }
                div(class: "link-card-description") { @link.description } if @link.description
              end
              if @link.image && !wide_image?
                img(src: @link.image, alt: "", width: "80", height: "80", class: "link-card-thumbnail", loading: "lazy")
              end
            end
          end
        end

        private

        def wide_image?
          @link.image && @link.wide_image?
        end

        def source
          [@link.site || @link.host, @link.author].compact.join(" · ")
        end
      end
    end
  end
end
