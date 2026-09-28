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
          <svg aria-hidden="true" width="68" height="48" viewBox="0 0 68 48" class="youtube-card-play"><path d="M66.5 7.7c-.8-2.9-2.5-5.4-5.4-6.2C55.8.1 34 0 34 0S12.2.1 6.9 1.5C4 2.3 2.3 4.8 1.5 7.7 0 13 0 24 0 24s0 11 1.5 16.3c.8 2.9 2.5 5.4 5.4 6.2C12.2 47.9 34 48 34 48s21.8-.1 27.1-1.5c2.9-.8 4.6-3.3 5.4-6.2C68 35 68 24 68 24s0-11-1.5-16.3z" fill="#f00"/><path d="M45 24 27 14v20z" fill="#fff"/></svg>
        SVG

        def initialize(site:, link:, feed: false)
          super(site:)
          @link = link
          @feed = feed
        end

        def view_template
          div(class: "youtube-card") do
            a(href: watch_url, **player_attributes, class: "youtube-card-player") do
              img(src: "https://i.ytimg.com/vi/#{@link.youtube}/hqdefault.jpg", alt: "", width: "480", height: "360",
                  **(@feed ? {} : {loading: "lazy"}))
              raw safe(PLAY_BUTTON) unless @feed
            end
            a(href: watch_url, class: "youtube-card-caption") do
              div(class: "display-caption card-source") { [@link.site || "YouTube", @link.author].compact.join(" · ") }
              div(class: "card-title") { @link.title || watch_url }
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
