# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class NotFoundPage < Base
        STYLES = <<~CSS
          .container {
            margin: 10px auto;
            max-width: 600px;
            text-align: center;
          }
          h1 {
            margin: 30px 0;
            font-size: 4em;
            line-height: 1;
            letter-spacing: -1px;
          }
        CSS

        def view_template
          render Layouts::ApplicationLayout.new(site:, layout: "default", seo: {url: "/404.html"}) do
            style(type: "text/css", media: "screen") { raw safe(STYLES) }
            div(class: "container") do
              h1 { "404" }
              p { strong { "Page not found :(" } }
              p { "The requested page could not be found." }
              p { a(href: "/") { "Go Back Home" } }
            end
          end
        end
      end
    end
  end
end
