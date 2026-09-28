# frozen_string_literal: true

module Layer22
  module Components
    module Layouts
      # The HTML shell every page renders into: head, nav, main and footer.
      class ApplicationLayout < Base
        FONTS_URL = "https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@300;400;500;600;700;900" \
          "&family=JetBrains+Mono:wght@400;500&display=swap"

        # +layout+ and +title+ name the body classes the site's CSS keys off, as
        # Jekyll's layout name and slugified page title did. +seo+ describes the
        # page for search engines and link previews (see Shared::SeoHead).
        def initialize(site:, layout:, title: nil, seo: {}, extra_css: nil)
          super(site:)
          @layout = layout
          @title = title
          @seo = seo
          @extra_css = extra_css
        end

        def view_template(&block)
          doctype
          html(lang: "en-US") do
            head do
              meta(charset: "UTF-8")
              meta(name: "viewport", content: "width=device-width, initial-scale=1")
              title { document_title }

              style { raw safe(site.css) }
              style { raw safe(@extra_css) } if @extra_css

              link(rel: "icon", type: "image/x-icon", href: "/favicon.ico", sizes: "48x48")
              link(rel: "icon", type: "image/svg+xml", href: "/favicon.svg")
              link(rel: "icon", type: "image/png", href: "/favicon-32x32.png")
              link(rel: "manifest", href: "/site.webmanifest")

              link(type: "application/atom+xml", rel: "alternate", href: absolute_url("/feed.xml"), title: config.title)
              link(rel: "alternate", type: "application/rss+xml", title: config.title, href: absolute_url("/rss.xml"))

              render Shared::SeoHead.new(site:, title: @title, **@seo)

              link(rel: "preconnect", href: "https://fonts.googleapis.com")
              link(href: FONTS_URL, rel: "stylesheet")
            end

            body(data: {instant_intensity: "viewport"}, class: "layout--#{@layout} #{slugify(@title)}".strip) do
              render Shared::Nav.new(site:)
              main(&block)
              render Shared::Footer.new(site:)
            end
          end
        end

        private

        def document_title
          if @title == "Home"
            "#{config.title} · #{config.tagline}"
          else
            "#{@title} · #{config.title}".strip
          end
        end
      end
    end
  end
end
