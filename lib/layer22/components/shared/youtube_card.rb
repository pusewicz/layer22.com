# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # A YouTube video a note links to: YouTube's own thumbnail with a play
      # button, which YoutubeScript swaps for the youtube-nocookie player on
      # click. Without JavaScript, or with +feed+, it is a plain link to the video.
      class YoutubeCard < Base
        # YouTube's play button, sized to sit centred on the thumbnail.
        PLAY_BUTTON = <<~SVG.chomp
          <svg aria-hidden="true" width="68" height="48" viewBox="0 0 68 48" class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2"><path d="M66.5 7.7c-.8-2.9-2.5-5.4-5.4-6.2C55.8.1 34 0 34 0S12.2.1 6.9 1.5C4 2.3 2.3 4.8 1.5 7.7 0 13 0 24 0 24s0 11 1.5 16.3c.8 2.9 2.5 5.4 5.4 6.2C12.2 47.9 34 48 34 48s21.8-.1 27.1-1.5c2.9-.8 4.6-3.3 5.4-6.2C68 35 68 24 68 24s0-11-1.5-16.3z" fill="#f00"/><path d="M45 24 27 14v20z" fill="#fff"/></svg>
        SVG

        def initialize(site:, link:, feed: false)
          super(site:)
          @link = link
          @feed = feed
        end

        def view_template
          div(class: "mt-4 max-w-[640px] overflow-hidden rounded-lg border border-[#D4D0CB] bg-white/50") do
            a(href: watch_url, **player_attributes, class: "relative block aspect-video bg-black") do
              img(src: "https://i.ytimg.com/vi/#{@link.youtube}/hqdefault.jpg", alt: "", width: "480", height: "360",
                  class: "block w-full h-full object-cover m-0", **(@feed ? {} : {loading: "lazy"}))
              raw safe(PLAY_BUTTON) unless @feed
            end
            a(href: watch_url, class: "block px-4 py-3 no-underline") do
              div(class: "font-display text-[13px] font-medium tracking-[0.06em] uppercase text-[#9B9895]") do
                [@link.site || "YouTube", @link.author].compact.join(" · ")
              end
              div(class: "mt-1 text-[17px] leading-6 text-[#0F0E0D]") { @link.title || watch_url }
            end
          end
        end

        private

        def watch_url
          "https://www.youtube.com/watch?v=#{@link.youtube}"
        end

        def player_attributes
          return {} if @feed

          {data: {youtube_id: @link.youtube}, aria_label: "Play #{@link.title || "video"}"}
        end
      end
    end
  end
end
