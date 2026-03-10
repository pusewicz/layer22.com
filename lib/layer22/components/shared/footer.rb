# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class Footer < Base
        def view_template
          footer(class: "w-full bg-[#ECEAE6] pt-16 pb-12") do
            div(class: "max-w-[1080px] mx-auto px-6") do
              div(class: "flex items-center justify-between mb-8") do
                span(class: "font-display text-[16px] font-semibold tracking-[0.08em] uppercase") do
                  span(class: "text-[#0F0E0D]") { "layer" }
                  span(class: "text-[#C00000]") { "|" }
                  span(class: "text-[#0F0E0D]") { "twenty" }
                  span(class: "text-[#C00000]") { "|" }
                  span(class: "text-[#0F0E0D]") { "two" }
                end
                div(class: "flex gap-8") do
                  a(href: config.github_url,
                    class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") { "GitHub" }
                  a(href: config.mastodon_url, rel: "me",
                    class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") { "Mastodon" }
                  a(href: "https://bsky.app/profile/pusewicz.bsky.social",
                    class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") { "Bluesky" }
                  a(href: config.twitter_url,
                    class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") { "X" }
                end
              end
              div(class: "w-full h-px bg-[#C8C4BE] mb-8")
              div(class: "flex items-center justify-between") do
                p(class: "font-display text-[14px] tracking-[0.06em] text-[#6B6968] m-0") do
                  plain "© 2004–"
                  time(datetime: Time.now.year.to_s) { Time.now.year.to_s }
                  plain " "
                  a(href: "/about", class: "text-[#6B6968] hover:text-[#0F0E0D]") { "Piotr Usewicz" }
                end
                span(class: "font-display text-[14px] tracking-[0.06em] uppercase text-[#6B6968]") { "Benicàrlo, Spain" }
              end
            end
          end
        end
      end
    end
  end
end
