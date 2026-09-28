# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class Footer < Base
        LINK_CLASS = "text-[13px] text-[#6B6968] hover:text-[#0F0E0D] no-underline"

        def view_template
          footer(class: "w-full bg-[#F5F3F0] pt-12 pb-10") do
            div(class: "max-w-[1080px] mx-auto px-6") do
              div(class: "w-full h-[1px] bg-[#D4D0CB] mb-4")
              div(class: "flex flex-col gap-3 md:flex-row md:items-center md:justify-between") do
                p(class: "text-[13px] text-[#9B9895] m-0") { "© #{Time.now.year} #{config.author_name}" }
                div(class: "flex gap-6") do
                  a(rel: "me", href: config.github_url, class: LINK_CLASS) { "GitHub" }
                  a(rel: "me", href: config.mastodon_url, class: LINK_CLASS) { "Mastodon" }
                  a(rel: "me atproto", href: "https://bsky.app/profile/pusewicz.bsky.social", class: LINK_CLASS) { "Bluesky" }
                  a(href: "https://iheartrss.com/", class: LINK_CLASS) { "I ♥ RSS" }
                end
              end
              p(class: "text-[12px] text-[#9B9895] text-center mt-4 mb-0") do
                plain "Pssst—I also run a "
                a(href: "https://layer22.games/", class: "text-[#6B6968] no-underline hover:text-[#0F0E0D]") { "game studio" }
                plain "."
              end
            end
          end
        end
      end
    end
  end
end
