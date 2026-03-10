# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class TilPage < Base
        def initialize(site:, til:, prev_til: nil, next_til: nil)
          super(site:)
          @til = til
          @prev_til = prev_til
          @next_til = next_til
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            page_title: "TIL: #{@til.title}",
            url: @til.permalink,
            type: "article"
          ) do
            article(class: "max-w-[720px] mx-auto px-6 py-16") do
              hgroup(class: "mb-12") do
                p(class: "text-[13px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-3 font-display") { "Today I Learned" }
                h1(class: "text-[42px] font-black tracking-[-0.03em] text-[#0F0E0D] leading-[1.1] mb-6 font-display uppercase") do
                  @til.title
                end
                render Shared::PostMeta.new(site:, post: @til)
              end
              div(class: "prose-content") { raw safe(@til.body_html) }
            end
            if @prev_til || @next_til
              nav(class: "max-w-[720px] mx-auto px-6 py-8 flex justify-between border-t border-[#C8C4BE]") do
                if @prev_til
                  a(href: @prev_til.permalink, rel: "prev",
                    class: "text-[14px] text-[#6B6968] hover:text-[#0F0E0D] font-display") do
                    plain "← TIL: "
                    plain @prev_til.title
                  end
                else
                  span
                end
                if @next_til
                  a(href: @next_til.permalink, rel: "next",
                    class: "text-[14px] text-[#6B6968] hover:text-[#0F0E0D] font-display") do
                    plain "TIL: "
                    plain @next_til.title
                    plain " →"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
