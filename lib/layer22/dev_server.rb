# frozen_string_literal: true

require "rack"

module Layer22
  class DevServer
    def self.build
      app = new

      Rack::Builder.new do
        use Rack::CommonLogger, Layer22.logger
        use Rack::Static, urls: ["/images", "/assets"], root: ".", header_rules: [[:all, {"cache-control" => "no-cache"}]]
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

      response = route(site, path)
      response || not_found(site)
    end

    private

    def build_site
      site = Site.new(config_path: @config_path)
      site.load_content
      site.instance_variable_set(:@css, Rendering::CSS.combined_css)
      site.instance_variable_set(:@syntax_css, Rendering::CSS.load_syntax)
      site
    end

    def route(site, path)
      case path
      when "/"
        html = Components::Pages::HomePage.new(site:).call
        ok(html)
      when "/feed.xml"
        xml = Generators::FeedGenerator.new(site).send(:build_feed, site.posts.sort_by(&:date).reverse.first(20))
        [200, {"content-type" => "application/atom+xml"}, [xml]]
      when "/sitemap.xml"
        xml = Generators::SitemapGenerator.new(site).send(:build_sitemap)
        [200, {"content-type" => "application/xml"}, [xml]]
      when "/404"
        html = Components::Pages::NotFoundPage.new(site:).call
        [404, {"content-type" => "text/html"}, [html]]
      else
        route_content(site, path)
      end
    end

    def route_content(site, path)
      normalized = path.chomp("/")

      # Post
      if (post = site.posts.find { |p| p.permalink == normalized || p.permalink == path })
        html = Components::Pages::PostPage.new(site:, post:).call
        return ok(html)
      end

      # TIL
      if (til = site.tils.find { |t| t.permalink.chomp("/") == normalized })
        sorted = site.tils.sort_by(&:date)
        idx = sorted.index(til)
        html = Components::Pages::TilPage.new(
          site:,
          til:,
          prev_til: idx > 0 ? sorted[idx - 1] : nil,
          next_til: sorted[idx + 1]
        ).call
        return ok(html)
      end

      # Static page
      if (page = site.pages.find { |p| p.permalink == normalized || p.permalink == path })
        html = Components::Pages::StaticPage.new(site:, page:).call
        return ok(html)
      end

      # Archive
      route_archive(site, path)
    end

    def route_archive(site, path)
      normalized = path.chomp("/")

      if normalized == "/archive"
        html = Components::Pages::ArchivePage.new(
          site:, title: "Archive",
          posts: site.posts.sort_by(&:date).reverse,
          url: "/archive"
        ).call
        return ok(html)
      end

      if normalized =~ %r{^/tags/([^/]+)$}
        tag_slug = ::Regexp.last_match(1)
        tag = site.posts.flat_map(&:tags).find { |t| t.downcase.gsub(/\s+/, "-") == tag_slug }
        if tag
          posts = site.posts.select { |p| p.tags.include?(tag) }.sort_by(&:date).reverse
          html = Components::Pages::TagPage.new(site:, tag:, posts:).call
          return ok(html)
        end
      end

      if normalized =~ %r{^/(\d{4})(?:/(\d{2})(?:/(\d{2}))?)?$}
        year, month, day = ::Regexp.last_match(1).to_i, ::Regexp.last_match(2)&.to_i, ::Regexp.last_match(3)&.to_i
        posts = site.posts.select do |p|
          p.date.year == year &&
            (month.nil? || p.date.month == month) &&
            (day.nil? || p.date.day == day)
        end.sort_by(&:date).reverse
        title = [year, month&.then { format("%02d", _1) }, day&.then { format("%02d", _1) }].compact.join("/")
        html = Components::Pages::ArchivePage.new(site:, title:, posts:, url: path).call
        return ok(html)
      end

      nil
    end

    def ok(html)
      [200, {"content-type" => "text/html"}, [html]]
    end

    def not_found(site)
      html = Components::Pages::NotFoundPage.new(site:).call
      [404, {"content-type" => "text/html"}, [html]]
    end
  end
end
