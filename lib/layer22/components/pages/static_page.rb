# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class StaticPage < Base
        def initialize(site:, page:)
          super(site:)
          @page = page
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            page_title: @page.title,
            url: @page.permalink
          ) do
            article(class: "max-w-[720px] mx-auto px-6 py-16 page") do
              h1(class: "text-[42px] font-black tracking-[-0.03em] text-[#0F0E0D] leading-[1.1] mb-8 font-display uppercase") do
                @page.title
              end
              div(class: "prose-content") { raw safe(@page.body_html) }
            end
          end
        end
      end
    end
  end
end
