# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class Footer < Base
        def view_template
          footer(class: "site-footer") do
            div(class: "site-width") do
              div(class: "site-footer-rule")
              div(class: "site-footer-row") do
                p(class: "site-footer-copyright") { "© #{Time.now.year} #{config.author_name}" }
                div(class: "site-footer-links") do
                  a(rel: "me", href: config.github_url) { "GitHub" }
                  a(rel: "me", href: config.mastodon_url) { "Mastodon" }
                  a(rel: "me atproto", href: "https://bsky.app/profile/pusewicz.bsky.social") { "Bluesky" }
                  a(href: "https://iheartrss.com/") { "I ♥ RSS" }
                end
              end
              p(class: "site-footer-aside") do
                plain "Pssst—I also run a "
                a(href: "https://layer22.games/") { "game studio" }
                plain "."
              end
            end
          end
        end
      end
    end
  end
end
