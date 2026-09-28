# frozen_string_literal: true

require "json"

module Layer22
  module Components
    module Shared
      # Search engine, Open Graph, Twitter and JSON-LD metadata, matching what the
      # jekyll-seo-tag plugin emitted for the Jekyll site.
      class SeoHead < Base
        KINDS = %i[home article page].freeze

        # +kind+ is :home for the front page, :article for posts and TILs, and
        # :page for everything else.
        def initialize(site:, title: nil, description: nil, url: "/", kind: :page,
                       published_at: nil, modified_at: nil)
          super(site:)
          raise ArgumentError, "unknown SEO kind #{kind.inspect}" unless KINDS.include?(kind)

          @title = title
          @description = description
          @url = url
          @kind = kind
          @published_at = published_at
          @modified_at = modified_at
        end

        def view_template
          meta(property: "og:title", content: headline)
          meta(name: "author", content: config.author_name)
          meta(property: "og:locale", content: "en_US")
          meta(name: "description", content: description)
          meta(name: "twitter:description", property: "og:description", content: description)
          link(rel: "canonical", href: canonical_url)
          meta(property: "og:url", content: canonical_url)
          meta(property: "og:site_name", content: site_name)
          meta(property: "og:type", content: article? ? "article" : "website")
          if article?
            meta(property: "article:published_time", content: @published_at.xmlschema)
            meta(property: "article:modified_time", content: modified_at.xmlschema)
          end
          meta(name: "twitter:card", content: "summary")
          meta(name: "twitter:title", content: headline)
          meta(name: "twitter:site", content: "@#{config.twitter["username"]}")
          meta(name: "twitter:creator", content: "@#{config.author["twitter"]}")
          script(type: "application/ld+json") { raw safe(JSON.generate(structured_data).gsub("</", "<\\/")) }
        end

        private

        def article?
          @kind == :article
        end

        # The site title as jekyll-seo-tag rendered it: its Markdown pass turned
        # the pipes of "layer|twenty|two" into table cell breaks.
        def site_name
          config.title.tr("|", " ")
        end

        def headline
          @title || site_name
        end

        def description
          @description || config.description
        end

        def canonical_url
          absolute_url(@url)
        end

        def modified_at
          @modified_at || @published_at
        end

        def structured_data
          data = {"@context" => "https://schema.org", "@type" => schema_type, "author" => person}
          data["dateModified"] = modified_at.xmlschema if modified_at
          data["datePublished"] = @published_at.xmlschema if article?
          data["description"] = description
          data["headline"] = headline
          data["mainEntityOfPage"] = {"@type" => "WebPage", "@id" => canonical_url} if article?
          data["name"] = config.author_name if @kind == :home
          data["publisher"] = publisher
          data["sameAs"] = config.social["links"] if @kind == :home
          data["url"] = canonical_url
          data
        end

        def schema_type
          {home: "WebSite", article: "BlogPosting", page: "WebPage"}.fetch(@kind)
        end

        def person
          {"@type" => "Person", "name" => config.author_name}
        end

        def publisher
          {
            "@type" => "Organization",
            "logo" => {"@type" => "ImageObject", "url" => absolute_url(config.logo)},
            "name" => config.author_name
          }
        end
      end
    end
  end
end
