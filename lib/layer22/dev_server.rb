# frozen_string_literal: true

require "rack"

module Layer22
  # Serves the site from source, rebuilding the requested page on every request.
  class DevServer
    def self.build
      app = new

      Rack::Builder.new do
        use Rack::CommonLogger, Layer22.logger
        use Rack::Static,
          urls: ["/images", "/assets", *Site::STATIC_FILES.map { |file| "/#{file}" }],
          root: ".",
          header_rules: [[:all, {"cache-control" => "no-cache"}]]
        run app
      end
    end

    def initialize(config_path: "site.yml")
      @config_path = config_path
    end

    def call(env)
      path = Rack::Request.new(env).path

      Layer22.reload!
      site = build_site

      feed(site, path) || page(site, path) || not_found(site)
    end

    private

    def build_site
      site = Site.new(config_path: @config_path)
      site.load_content
      site.instance_variable_set(:@css, Rendering::CSS.combined_css)
      site.instance_variable_set(:@syntax_css, Rendering::CSS.load_syntax)
      site
    end

    def feed(site, path)
      case path
      when "/feed.xml"
        [200, {"content-type" => "application/atom+xml"}, [Generators::FeedGenerator.new(site).build_feed]]
      when "/sitemap.xml"
        [200, {"content-type" => "application/xml"}, [Generators::SitemapGenerator.new(site).build_sitemap]]
      end
    end

    # Finds the page for +path+ the way Cloudflare Pages does: "/about" and
    # "/about.html" serve about.html, "/2015" and "/2015/" serve 2015/index.html.
    def page(site, path)
      routes = site.routes
      url = [path, path.delete_suffix(".html"), path.chomp("/"), "#{path}/"].find { |candidate| routes.key?(candidate) }
      [200, {"content-type" => "text/html"}, [routes.fetch(url).call]] if url
    end

    def not_found(site)
      html = Components::Pages::NotFoundPage.new(site:).call
      [404, {"content-type" => "text/html"}, [html]]
    end
  end
end
