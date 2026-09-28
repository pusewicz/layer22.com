# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  # Builds the real site (the repository's own content, not the fixture) and
  # checks what must hold for any content: every page renders, every feed is
  # well formed, and the links every page shares resolve.
  class SmokeTest < TestCase
    REPO_ROOT = File.expand_path("..", __dir__)
    GENERATED_FILES = %w[/feed.xml /rss.xml /notes/feed.xml /sitemap.xml /robots.txt /.well-known/webfinger].freeze

    class << self
      # The real site, loaded once.
      def site
        @site ||= Dir.chdir(REPO_ROOT) { Site.new.load_content.load_css }
      end

      def routes
        @routes ||= site.routes
      end
    end

    def test_every_route_renders_a_parseable_html_document
      problems = in_repo { routes.filter_map { |url, render| (problem = problem_with(render.call)) && "#{url}: #{problem}" } }

      assert_empty problems
      assert_operator routes.size, :>, 100
    end

    def test_route_urls_are_unique_across_content_archives_and_redirects
      redirects = site.posts.sum { |post| post.redirect_from.size }
      archives = Generators::ArchivesGenerator.new(site).archives.size
      expected = 2 + site.posts.size + site.tils.size + site.notes.size + site.pages.size + archives + redirects

      assert_equal expected, routes.size
    end

    def test_no_two_routes_share_an_output_file_or_replace_a_generated_file
      paths = routes.keys.group_by { |url| OutputPath.for(url, output_dir: "_site") }
      generated = GENERATED_FILES.map { |url| File.join("_site", url) }

      assert_empty paths.select { |_path, urls| urls.size > 1 }
      assert_empty paths.keys & generated
    end

    def test_generators_write_well_formed_files
      Dir.mktmpdir do |dir|
        capture_io { generate_all(dir) }

        assert_atom_feed dir
        assert_rss_feeds dir
        assert_sitemap dir
        assert_webfinger_and_robots dir
      end
    end

    def test_home_page_nav_and_footer_links_resolve
      home = parse_html(routes.fetch("/").call)
      hrefs = home.css("nav a[href^='/'], footer a[href^='/']").map { |a| a["href"].sub(/[?#].*\z/, "") }.uniq

      assert_includes hrefs, "/archive"
      assert_empty hrefs.reject { |href| resolves?(href) }
    end

    def test_home_page_head_links_to_site_files_resolve
      home = parse_html(routes.fetch("/").call)
      hrefs = home.css("head link[href^='/']").map { |link| link["href"] }

      assert_includes hrefs, "/favicon.ico"
      assert_empty hrefs.reject { |href| resolves?(href) }
    end

    def test_every_static_file_the_build_copies_exists
      assert_empty Site::STATIC_FILES.reject { |file| File.file?(File.join(REPO_ROOT, file)) }
      assert_empty Site::STATIC_DIRS.reject { |dir| File.directory?(File.join(REPO_ROOT, dir)) }
    end

    private

    def site
      self.class.site
    end

    def routes
      self.class.routes
    end

    def in_repo(&)
      Dir.chdir(REPO_ROOT, &)
    end

    # Returns what is wrong with the rendered +html+ page, or nil.
    def problem_with(html)
      return "empty" if html.to_s.empty?
      return "no doctype" unless html.match?(/\A<!doctype html>/i)

      document = parse_html(html)
      return "no title" if document.at_css("html[lang] > head > title")&.text.to_s.empty?

      "no body" unless document.at_css("html > body")
    end

    def generate_all(dir)
      in_repo do
        Generators::FeedGenerator.new(site).generate(output_dir: dir)
        Generators::RssGenerator.channels(site).each { |channel| Generators::RssGenerator.new(site, channel).generate(output_dir: dir) }
        Generators::SitemapGenerator.new(site).generate(output_dir: dir)
        Generators::WebfingerGenerator.new(site).generate(output_dir: dir)
        Generators::RobotsGenerator.new(site).generate(output_dir: dir)
      end
    end

    def assert_atom_feed(dir)
      feed = parse_xml(File.read(File.join(dir, "feed.xml"))).remove_namespaces!
      ids = feed.xpath("/feed/entry/id").map(&:text)

      assert_equal [site.posts.size, Generators::FeedGenerator::LIMIT].min, ids.size
      assert_equal site.posts.last(ids.size).reverse.map { |post| "#{site.config.site_url}#{post.permalink}" }, ids
      refute_empty feed.at_xpath("/feed/entry/content").text
    end

    def assert_rss_feeds(dir)
      limit = Generators::RssGenerator::LIMIT
      posts = parse_xml(File.read(File.join(dir, "rss.xml")))
      notes = parse_xml(File.read(File.join(dir, "notes", "feed.xml")))

      assert_equal [site.posts.size, limit].min, posts.xpath("/rss/channel/item").size
      assert_equal [site.notes.size, limit].min, notes.xpath("/rss/channel/item").size
      assert(notes.xpath("/rss/channel/item/link").all? { |link| link.text.start_with?("#{site.config.site_url}/notes/") })
    end

    def assert_sitemap(dir)
      locs = parse_xml(File.read(File.join(dir, "sitemap.xml"))).remove_namespaces!.xpath("/urlset/url/loc").map(&:text)
      site_url = site.config.site_url

      assert_equal locs.uniq, locs
      assert(locs.all? { |loc| loc.start_with?("#{site_url}/") })
      assert_includes locs, "#{site_url}/"
      assert_empty site.posts.map { |post| "#{site_url}#{post.permalink}" } - locs
      assert_equal File.exist?(File.join(REPO_ROOT, "piotr-usewicz-resume.pdf")), locs.include?("#{site_url}/piotr-usewicz-resume.pdf")
    end

    def assert_webfinger_and_robots(dir)
      mastodon = site.config.mastodon
      webfinger = JSON.parse(File.read(File.join(dir, ".well-known", "webfinger")))

      assert_equal "acct:#{mastodon["username"]}@#{mastodon["instance"]}", webfinger["subject"]
      assert_includes File.read(File.join(dir, "robots.txt")), "Sitemap: #{site.config.site_url}/sitemap.xml"
    end

    # Whether +href+, a root-relative URL, leads somewhere once the site is
    # deployed: a page, a generated file, a copied static file or a redirect.
    def resolves?(href)
      routes.key?(href) || GENERATED_FILES.include?(href) || static_file?(href) || redirect_sources.include?(href)
    end

    def static_file?(href)
      path = href.delete_prefix("/")
      copied = Site::STATIC_FILES.include?(path) || Site::STATIC_DIRS.any? { |dir| path.start_with?("#{dir}/") }
      copied && File.file?(File.join(REPO_ROOT, path))
    end

    def redirect_sources
      @redirect_sources ||= File.readlines(File.join(REPO_ROOT, "_redirects"), chomp: true)
        .reject { |line| line.strip.empty? || line.start_with?("#") }
        .map { |line| line.split.first }
    end
  end
end
