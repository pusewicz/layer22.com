# frozen_string_literal: true

require "cgi/escape"
require "json"
require "phlex"

module Layer22
  module Components
    module Pages
      # A client-side redirect for moved URLs, as jekyll-redirect-from wrote them.
      # Cloudflare's _redirects handles most of these; the page covers the rest.
      class RedirectPage < Phlex::HTML
        # +to+ is the absolute URL to send visitors to.
        def initialize(to:)
          @to = to
        end

        def view_template
          doctype
          html(lang: "en-US") do
            meta(charset: "utf-8")
            title { "Redirecting…" }
            link(rel: "canonical", href: @to)
            script { raw safe("location=#{@to.to_json.gsub("</", "<\\/")}") }
            # Phlex refuses http-equiv attributes, so this one tag is written by hand.
            raw safe(%(<meta http-equiv="refresh" content="0; url=#{CGI.escapeHTML(@to)}">))
            meta(name: "robots", content: "noindex")
            h1 { "Redirecting…" }
            a(href: @to) { "Click here if you are not redirected." }
          end
        end
      end
    end
  end
end
