# frozen_string_literal: true

module Layer22
  module Generators
    class RedirectGenerator
      def initialize(site)
        @site = site
      end

      def generate(output_dir: "_site")
        @site.posts.each do |post|
          post.redirect_from.each do |from_path|
            write_redirect(from_path, post.permalink, output_dir)
          end
        end
      end

      private

      def write_redirect(from_path, to_path, output_dir)
        html = <<~HTML
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="UTF-8">
              <meta http-equiv="refresh" content="0; url=#{to_path}">
              <link rel="canonical" href="#{to_path}">
              <title>Redirecting...</title>
            </head>
            <body>
              <p>Redirecting to <a href="#{to_path}">#{to_path}</a></p>
            </body>
          </html>
        HTML

        @site.write_page(from_path, html, output_dir:)
      end
    end
  end
end
