# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class NotFoundPage < Base
        def view_template
          render Layouts::ApplicationLayout.new(site:, page_title: "404 — Page Not Found") do
            div(class: "max-w-[720px] mx-auto px-6 py-32 text-center font-display") do
              p(class: "text-[13px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-4") { "404" }
              h1(class: "text-[72px] font-black tracking-[-0.03em] uppercase text-[#0F0E0D] leading-none mb-8") do
                "Page Not Found"
              end
              p(class: "text-[20px] font-light text-[#6B6968] mb-12") do
                "The page you're looking for doesn't exist or has moved."
              end
              a(href: "/",
                class: "inline-flex items-center justify-center py-[18px] px-12 bg-[#C00000] text-[16px] font-bold tracking-[0.12em] uppercase text-[#E8E6E3] no-underline hover:opacity-90") do
                "Go Home"
              end
            end
          end
        end
      end
    end
  end
end
