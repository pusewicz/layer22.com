# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # The front page: an h-card introduction and the three most recent posts.
      class HomePage < Base
        AVATAR_URL = "https://www.gravatar.com/avatar/dcbf676f860477e44b275cae5d6318a4.jpg?s=176"

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "home",
            title: "Home",
            seo: {kind: :home, modified_at: site.posts.last&.date}
          ) do
            introduction
            recent_writing
          end
        end

        private

        def introduction
          section(class: "w-full bg-[#F5F3F0] pt-16 pb-0") do
            div(class: "h-card max-w-[1080px] mx-auto px-6") do
              div(class: "flex items-center gap-5 mb-6") do
                img(src: AVATAR_URL, width: "176", height: "176", alt: config.author_name,
                    class: "u-photo w-[88px] h-[88px] rounded-full object-cover shrink-0", loading: "lazy")
                div do
                  h1(class: "p-name font-display text-[52px] font-bold tracking-[-0.02em] text-[#0F0E0D] leading-none m-0") do
                    config.author_name
                  end
                  a(class: "u-url u-uid mt-1 block text-[13px] text-[#9B9895] no-underline hover:text-[#6B6968]",
                    rel: "me", href: absolute_url("/")) { "layer22.com" }
                end
              end
              div(class: "max-w-[580px]") do
                p(class: "p-note text-[18px] leading-7 tracking-[0.01em] text-[#2A2826] mt-0 mb-4") do
                  "I've been writing software professionally since 2005 — first in PHP, then Rails from the very " \
                    "early days. I care about readable code, sensible defaults, and software that stays maintainable " \
                    "long after the initial excitement fades."
                end
                p(class: "text-[15px] leading-[22px] text-[#6B6968] m-0") do
                  plain "Based in "
                  span(class: "p-locality") { "Benicàrlo" }
                  plain ", "
                  span(class: "p-country-name") { "Spain" }
                end
              end
            end
          end
        end

        def recent_writing
          section(class: "w-full bg-[#F5F3F0] pt-12 pb-0") do
            div(class: "h-feed max-w-[1080px] mx-auto px-6") do
              div(class: "flex items-baseline justify-between border-b border-[#C8C4BE] pb-3 mb-1") do
                span(class: "p-name font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968]") do
                  "Recent Writing"
                end
                a(href: "/archive", class: "text-[14px] text-[#C00000] underline hover:text-[#8A0000]") { "View all" }
              end
              site.posts.last(3).reverse_each do |post|
                div(class: "h-entry flex items-baseline justify-between py-[11px] border-b border-[#E2DFDB]") do
                  a(href: absolute_url(post.permalink),
                    class: "p-name u-url text-[17px] text-[#0F0E0D] no-underline hover:text-[#C00000] leading-6") { post.title }
                  time(class: "dt-published font-display text-[13px] tracking-[0.06em] uppercase text-[#9B9895] shrink-0 ml-10",
                       datetime: post.date.xmlschema) { format_date(post.date, "%b %Y") }
                end
              end
            end
          end
        end
      end
    end
  end
end
