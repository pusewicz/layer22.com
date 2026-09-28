# frozen_string_literal: true

module Layer22
  module Generators
    class RobotsGenerator
      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        content = <<~ROBOTS
          User-agent: *
          Disallow: /cdn-cgi/

          User-agent: *
          Allow: /

          Sitemap: #{@config.site_url}/sitemap.xml
        ROBOTS

        dest = File.join(output_dir, "robots.txt")
        File.write(dest, content)
        puts "Generated #{dest}"
      end
    end
  end
end
