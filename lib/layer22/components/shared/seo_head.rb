# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class SeoHead < Base
        def initialize(site:, page_title: nil, description: nil, url: nil, image: nil, type: "website")
          super(site:)
          @page_title = page_title
          @description = description
          @url = url
          @image = image
          @type = type
        end

        def view_template
          full_title = if @page_title
            "#{@page_title} · #{config.title}"
          else
            "#{config.title} · #{config.tagline}"
          end
          desc = @description || config.description
          canonical = @url ? "#{config.site_url}#{@url}" : config.site_url
          image_url = @image || "#{config.site_url}#{config.logo}"

          # Basic meta
          meta(name: "description", content: desc)

          # Open Graph
          meta(property: "og:title", content: full_title)
          meta(property: "og:description", content: desc)
          meta(property: "og:url", content: canonical)
          meta(property: "og:image", content: image_url)
          meta(property: "og:type", content: @type)
          meta(property: "og:site_name", content: config.title)

          # Twitter Card
          meta(name: "twitter:card", content: config.twitter["card"] || "summary_large_image")
          meta(name: "twitter:site", content: "@#{config.twitter["username"]}")
          meta(name: "twitter:title", content: full_title)
          meta(name: "twitter:description", content: desc)
          meta(name: "twitter:image", content: image_url)

          # Canonical
          link(rel: "canonical", href: canonical)

          # Feed
          link(rel: "alternate", type: "application/atom+xml",
               title: "#{config.title} - Atom Feed",
               href: "#{config.site_url}/feed.xml")
        end
      end
    end
  end
end
