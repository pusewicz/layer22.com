# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class Nav < Base
        LINK_CLASS = "font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] " \
          "hover:text-[#0F0E0D] no-underline"
        LINKS = {"Writing" => "/archive", "About" => "/about", "Resume" => "/resume", "Contact" => "/contact"}.freeze

        def view_template
          nav(class: "w-full bg-[#F5F3F0]") do
            div(class: "max-w-[1080px] mx-auto px-6 h-[56px] flex items-center justify-between") do
              a(href: "/", class: "no-underline flex items-center gap-3") do
                img(src: "/apple-touch-icon.png", alt: "", width: "32", height: "32", class: "rounded-lg", loading: "lazy")
                span(style: "font-family: 'JetBrains Mono', monospace; letter-spacing: -0.02em;",
                     class: "text-[17px] font-medium") do
                  span(class: "text-[#1A1714]") { "layer" }
                  span(class: "text-[#B30000]") { "|" }
                  span(class: "text-[#1A1714]") { "twenty" }
                  span(class: "text-[#B30000]") { "|" }
                  span(class: "text-[#1A1714]") { "two" }
                end
              end
              div(class: "hidden md:flex items-center gap-8") do
                LINKS.each { |label, href| a(href:, class: LINK_CLASS) { label } }
              end
            end
          end
        end
      end
    end
  end
end
