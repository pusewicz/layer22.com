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

        path = from_path.chomp("/")
        # If path ends with .html, write directly; otherwise create dir/index.html
        dest = if path.end_with?(".html")
          File.join(output_dir, path)
        else
          File.join(output_dir, path, "index.html")
        end
        FileUtils.mkdir_p(File.dirname(dest))
        File.write(dest, html)
        puts "Generated redirect: #{path} → #{to_path}"
      end
    end
  end
end
