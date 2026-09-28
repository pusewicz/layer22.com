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
            layout: "til",
            title: @til.title,
            seo: {
              kind: :article,
              url: @til.permalink,
              description: @til.description,
              published_at: @til.date,
              modified_at: @til.last_modified_at
            },
            extra_css: site.syntax_css
          ) do
            article(class: "til") do
              hgroup { h1 { "TIL: #{@til.title}" } }
              section { raw safe(@til.body_html) }
              nav(style: "display: flex; justify-content: space-between;") do
                if @prev_til || @next_til
                  div { a(href: @prev_til.permalink, rel: "prev") { "← TIL: #{@prev_til.title}" } if @prev_til }
                  div { a(href: @next_til.permalink, rel: "next") { "TIL: #{@next_til.title} →" } if @next_til }
                end
              end
            end
          end
        end
      end
    end
  end
end
