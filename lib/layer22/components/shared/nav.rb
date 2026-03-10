# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class Nav < Base
        def view_template
          nav(class: "w-full bg-[#F5F3F0] border-b border-[#D4D0CB]") do
            div(class: "max-w-[1080px] mx-auto px-6 h-20 flex items-center justify-between") do
              a(href: "/", class: "flex items-center gap-3 no-underline") do
                svg(xmlns: "http://www.w3.org/2000/svg", width: "28", height: "28",
                    viewBox: "0 0 24 24", fill: "none", stroke: "#C00000",
                    "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round") do |s|
                  s.circle(cx: "12", cy: "12", r: "10")
                  s.circle(cx: "12", cy: "12", r: "6")
                  s.circle(cx: "12", cy: "12", r: "2")
                end
                span(class: "font-display text-[16px] font-semibold tracking-[0.08em] uppercase") do
                  span(class: "text-[#0F0E0D]") { "layer" }
                  span(class: "text-[#C00000]") { "|" }
                  span(class: "text-[#0F0E0D]") { "twenty" }
                  span(class: "text-[#C00000]") { "|" }
                  span(class: "text-[#0F0E0D]") { "two" }
                end
              end
              div(class: "hidden md:flex items-center gap-10") do
                a(href: "/about", class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") { "About" }
                a(href: "/archive", class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") { "Writing" }
                a(href: "/contact", class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") { "Contact" }
              end
            end
          end
        end
      end
    end
  end
end
