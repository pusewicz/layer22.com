# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class Nav < Base
        LINKS = {
          "Writing" => "/archive", "Notes" => "/notes/", "About" => "/about", "Resume" => "/resume", "Contact" => "/contact"
        }.freeze

        def view_template
          nav do
            div(class: "site-width site-nav-bar") do
              a(href: "/", class: "wordmark") do
                img(src: "/apple-touch-icon.png", alt: "", width: "32", height: "32", loading: "lazy")
                span(class: "wordmark-text") do
                  span { "layer" }
                  span(class: "wordmark-pipe") { "|" }
                  span { "twenty" }
                  span(class: "wordmark-pipe") { "|" }
                  span { "two" }
                end
              end
              div(class: "site-nav-links") do
                LINKS.each { |label, href| a(href:, class: "display-label") { label } }
              end
            end
          end
        end
      end
    end
  end
end
