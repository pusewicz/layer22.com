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
          a(href: @link.url,
            class: "block mt-4 max-w-[640px] overflow-hidden rounded-lg border border-[#D4D0CB] bg-white/50 no-underline " \
                   "hover:border-[#9B9895]") do
            if wide_image?
              img(src: @link.image, alt: "", width: @link.image_width.to_s, height: @link.image_height.to_s,
                  class: "block w-full h-auto aspect-video object-cover m-0", loading: "lazy")
            end
            div(class: "flex gap-4 px-4 py-3") do
              div(class: "min-w-0 flex-1") do
                div(class: "font-display text-[13px] font-medium tracking-[0.06em] uppercase text-[#9B9895]") { source }
                div(class: "mt-1 text-[17px] leading-6 text-[#0F0E0D]") { @link.title || @link.url }
                if @link.description
                  div(class: "mt-1 text-[14px] leading-5 text-[#6B6968] line-clamp-2") { @link.description }
                end
              end
              if @link.image && !wide_image?
                img(src: @link.image, alt: "", width: "80", height: "80",
                    class: "block w-20 h-20 shrink-0 rounded object-cover m-0", loading: "lazy")
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
