# frozen_string_literal: true

require "phlex"

module Layer22
  module Components
    module Shared
      # Swaps a YouTube thumbnail (YoutubeCard) for the youtube-nocookie player
      # when clicked, so nothing loads from YouTube's player until then.
      # Modified clicks still open the video on YouTube.
      class YoutubeScript < Phlex::HTML
        SCRIPT = <<~JS
          document.addEventListener("click", (event) => {
            const link = event.target.closest("a[data-youtube-id]");
            if (!link || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

            event.preventDefault();
            const iframe = document.createElement("iframe");
            iframe.src = `https://www.youtube-nocookie.com/embed/${encodeURIComponent(link.dataset.youtubeId)}?autoplay=1`;
            iframe.title = link.getAttribute("aria-label");
            iframe.allow = "autoplay; encrypted-media; picture-in-picture; fullscreen";
            const player = document.createElement("div");
            player.className = "youtube-card-player";
            player.append(iframe);
            link.replaceWith(player);
          });
        JS

        def view_template
          script { raw safe(SCRIPT) }
        end
      end
    end
  end
end
