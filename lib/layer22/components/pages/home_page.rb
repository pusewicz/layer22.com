# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # The front page: an h-card introduction and the three most recent posts.
      class HomePage < Base
        AVATAR_URL = "https://www.gravatar.com/avatar/dcbf676f860477e44b275cae5d6318a4.jpg?s=176"

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "home",
            title: "Home",
            seo: {kind: :home, modified_at: site.posts.last&.date}
          ) do
            introduction
            recent_writing
          end
        end

        private

        def introduction
          section(class: "home-intro") do
            div(class: "h-card site-width") do
              div(class: "home-identity") do
                img(src: AVATAR_URL, width: "176", height: "176", alt: config.author_name,
                    class: "u-photo author-photo", loading: "lazy")
                div do
                  h1(class: "p-name home-name") { config.author_name }
                  a(class: "u-url u-uid home-url", rel: "me", href: absolute_url("/")) { "layer22.com" }
                end
              end
              div(class: "home-bio") do
                p(class: "p-note home-note") do
                  "I've been writing software professionally since 2005 — first in PHP, then Rails from the very " \
                    "early days. I care about readable code, sensible defaults, and software that stays maintainable " \
                    "long after the initial excitement fades."
                end
                p(class: "home-location") do
                  plain "Based in "
                  span(class: "p-locality") { "Benicàrlo" }
                  plain ", "
                  span(class: "p-country-name") { "Spain" }
                end
              end
            end
          end
        end

        def recent_writing
          section(class: "recent-writing") do
            div(class: "h-feed site-width") do
              div(class: "section-head") do
                span(class: "p-name display-label") { "Recent Writing" }
                a(href: "/archive") { "View all" }
              end
              site.posts.last(3).reverse_each do |post|
                div(class: "h-entry post-row") do
                  a(href: absolute_url(post.permalink), class: "p-name u-url") { post.title }
                  time(class: "dt-published display-caption post-row-date", datetime: post.date.xmlschema) do
                    format_date(post.date, "%b %Y")
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
