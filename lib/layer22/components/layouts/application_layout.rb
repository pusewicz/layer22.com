# frozen_string_literal: true

module Layer22
  module Components
    module Layouts
      class ApplicationLayout < Base
        def initialize(site:, page_title: nil, description: nil, url: nil, image: nil,
                       type: "website", extra_css: nil)
          super(site:)
          @page_title = page_title
          @description = description
          @url = url
          @image = image
          @type = type
          @extra_css = extra_css
        end

        def view_template(&block)
          doctype
          html(lang: "en-US") do
            head do
              meta(charset: "UTF-8")
              meta(name: "viewport", content: "width=device-width, initial-scale=1")
              title_text = if @page_title
                "#{@page_title} · #{config.title}"
              else
                "#{config.title} · #{config.tagline}"
              end
              title { title_text }

              # Inlined CSS
              style { raw safe(site.css) }
              if @extra_css
                style { raw safe(@extra_css) }
              end

              # Favicons
              link(rel: "icon", type: "image/x-icon", href: "/favicon.ico", sizes: "48x48")
              link(rel: "icon", type: "image/svg+xml", href: "/favicon.svg")
              link(rel: "icon", type: "image/png", href: "/favicon-32x32.png")
              link(rel: "manifest", href: "/site.webmanifest")

              # Fonts
              link(rel: "preconnect", href: "https://fonts.googleapis.com")
              link(href: "https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@300;400;500;600;700;900&display=swap",
                   rel: "stylesheet")

              # SEO
              render Shared::SeoHead.new(
                site:,
                page_title: @page_title,
                description: @description,
                url: @url,
                image: @image,
                type: @type
              )
            end

            body do
              render Shared::Nav.new(site:)
              main { yield }
              render Shared::Footer.new(site:)
            end
          end
        end
      end
    end
  end
end
