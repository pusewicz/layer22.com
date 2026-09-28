# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  class SiteTest < TestCase
    FIXTURE_ROUTES = %w[
      /
      /hello-world /review /cafe
      /til/2021/03/05/first-til/ /til/2021/03/20/second-til/ /til/2022/01/10/third-til/
      /notes/2021/05/01/093000/ /notes/2021/05/02/101500/ /notes/2021/05/03/121000/
      /notes/2021/05/04/080000/ /notes/2021/05/05/200000/ /notes/2021/05/06/070000/
      /about /archive /categories /colophon /hidden /moved /notes/ /tags /til
      /404.html
      /tags/ruby/ /tags/rails/ /tags/café/
      /2021/ /2019/ /2021/06/ /2021/01/ /2019/03/ /2021/06/01/ /2021/01/01/ /2019/03/14/
      /old-review /2020/old-review.html
    ].freeze

    def test_routes_cover_every_content_type_archives_and_redirects_in_order
      assert_equal FIXTURE_ROUTES, fixture_site.routes.keys
    end

    def test_every_route_renders_an_html_document
      fixture_site.routes.each do |url, render|
        html = render.call

        assert_match(/\A<!doctype html>/i, html, url)
        refute_nil parse_html(html).at_css("html[lang]"), url
      end
    end

    def test_post_route_renders_the_post
      html = parse_html(fixture_site.routes["/hello-world"].call)

      assert_equal "Hello, World · fixture|site", html.at_css("title").text
      assert_includes html.at_css("body")["class"], "layout--post"
    end

    def test_page_routes_render_with_their_layout
      routes = fixture_site.routes

      assert_includes parse_html(routes["/about"].call).at_css("main").text, "Some words about the fixture."
      assert_includes parse_html(routes["/til"].call).text, "Third TIL"
      assert_includes parse_html(routes["/notes/"].call).text, "A plain note with no link."
      assert_equal "About · fixture|site", parse_html(routes["/about"].call).at_css("title").text
    end

    def test_page_layouts_default_to_page
      html = parse_html(fixture_site.routes["/colophon"].call)

      assert_includes html.at_css("body")["class"], "layout--page"
      assert_includes html.at_css(".page-body").inner_html, %(<p class="raw">Hand-written HTML.</p>)
    end

    def test_home_and_not_found_routes
      routes = fixture_site.routes

      assert_equal "fixture|site · A fixture tagline", parse_html(routes["/"].call).at_css("title").text
      assert_includes parse_html(routes["/404.html"].call).text, "Page not found"
    end

    def test_page_with_redirect_to_renders_a_redirect
      html = parse_html(fixture_site.routes["/moved"].call)

      assert_equal "https://elsewhere.test/landing", html.at_css("link[rel=canonical]")["href"]
      assert_equal "Redirecting…", html.at_css("title").text
    end

    def test_redirect_from_routes_redirect_to_the_posts_absolute_url
      routes = fixture_site.routes

      %w[/old-review /2020/old-review.html].each do |url|
        html = parse_html(routes[url].call)

        assert_equal "https://example.test/review", html.at_css("link[rel=canonical]")["href"], url
        assert_includes html.at_css("script").text, "https://example.test/review"
      end
    end

    def test_til_routes_link_to_their_neighbours_without_wrapping_around
      assert_equal({"prev" => nil, "next" => "/til/2021/03/20/second-til/"}, neighbour_links("/til/2021/03/05/first-til/"))
      assert_equal({"prev" => "/til/2021/03/05/first-til/", "next" => "/til/2022/01/10/third-til/"}, neighbour_links("/til/2021/03/20/second-til/"))
      assert_equal({"prev" => "/til/2021/03/20/second-til/", "next" => nil}, neighbour_links("/til/2022/01/10/third-til/"))
    end

    def test_note_routes_link_to_their_neighbours_without_wrapping_around
      assert_equal({"prev" => nil, "next" => "/notes/2021/05/02/101500/"}, neighbour_links("/notes/2021/05/01/093000/"))
      assert_equal({"prev" => "/notes/2021/05/02/101500/", "next" => "/notes/2021/05/04/080000/"}, neighbour_links("/notes/2021/05/03/121000/"))
      assert_equal({"prev" => "/notes/2021/05/05/200000/", "next" => nil}, neighbour_links("/notes/2021/05/06/070000/"))
    end

    def test_a_site_with_a_single_til_has_no_neighbour_links
      with_site({"_til/2021/03/2021-03-05-only.md" => "---\ntitle: Only\n---\n\nText.\n"}) do
        site = Site.new.load_content.load_css
        page = parse_html(site.routes.fetch("/til/2021/03/05/only/").call)

        assert_nil page.at_css("a[rel=prev]")
        assert_nil page.at_css("a[rel=next]")
      end
    end

    def test_two_pages_claiming_the_same_url_raise
      files = {
        "_pages/one.md" => "---\ntitle: One\npermalink: /same\n---\n",
        "_pages/two.md" => "---\ntitle: Two\npermalink: /same\n---\n"
      }
      with_site(files) do
        error = assert_raises(ArgumentError) { Site.new.load_content.routes }

        assert_equal "two pages claim /same", error.message
      end
    end

    def test_a_page_colliding_with_a_post_raises
      files = {
        "_posts/2019-03-14-hello-world.md" => "---\ntitle: Hello\n---\n\nBody.\n",
        "_pages/clash.md" => "---\ntitle: Clash\npermalink: /hello-world\n---\n"
      }
      with_site(files) do
        error = assert_raises(ArgumentError) { Site.new.load_content.routes }

        assert_equal "two pages claim /hello-world", error.message
      end
    end

    def test_a_page_colliding_with_an_archive_raises
      files = {
        "_posts/2021-03-01-post.md" => "---\ntitle: Post\n---\n\nBody.\n",
        "_pages/year.md" => "---\ntitle: Year\npermalink: /2021/\n---\n"
      }
      with_site(files) do
        error = assert_raises(ArgumentError) { Site.new.load_content.routes }

        assert_equal "two pages claim /2021/", error.message
      end
    end

    def test_a_redirect_from_colliding_with_a_page_raises
      files = {
        "_posts/2021-03-01-post.md" => "---\ntitle: Post\nredirect_from: [/about]\n---\n\nBody.\n",
        "_pages/about.md" => "---\ntitle: About\npermalink: /about\n---\n"
      }
      with_site(files) do
        error = assert_raises(ArgumentError) { Site.new.load_content.routes }

        assert_equal "two pages claim /about", error.message
      end
    end

    def test_two_posts_with_the_same_slug_raise
      files = {
        "_posts/2021-03-01-same.md" => "---\ntitle: One\n---\n\nBody.\n",
        "_posts/2021-04-01-same.md" => "---\ntitle: Two\n---\n\nBody.\n"
      }
      with_site(files) do
        error = assert_raises(ArgumentError) { Site.new.load_content.routes }

        assert_equal "two pages claim /same", error.message
      end
    end

    def test_a_page_with_an_unknown_layout_raises_when_it_is_rendered
      with_site({"_pages/odd.md" => "---\ntitle: Odd\npermalink: /odd\nlayout: bogus\n---\n"}) do
        routes = Site.new.load_content.routes

        error = assert_raises(ArgumentError) { routes.fetch("/odd").call }
        assert_equal "_pages/odd.md: unknown layout \"bogus\"", error.message
      end
    end

    def test_build_fails_on_a_page_with_an_unknown_layout
      with_site({"_pages/odd.md" => "---\ntitle: Odd\npermalink: /odd\nlayout: bogus\n---\n"}) do |dir|
        error = assert_raises(ArgumentError) { capture_io { Site.new.build(output_dir: File.join(dir, "_site"), skip_webp: true) } }

        assert_match(/unknown layout "bogus"/, error.message)
      end
    end

    def test_tags_are_in_order_of_first_use_with_each_tags_posts_newest_first
      tags = fixture_site.tags

      assert_equal %w[ruby rails Café], tags.keys
      assert_equal %w[cafe review hello-world], tags["ruby"].map(&:slug)
      assert_equal %w[hello-world], tags["rails"].map(&:slug)
      assert_equal %w[cafe], tags["Café"].map(&:slug)
    end

    def test_categories_are_ordered_like_tags
      categories = fixture_site.categories

      assert_equal %w[code life], categories.keys
      assert_equal %w[hello-world], categories["code"].map(&:slug)
      assert_equal %w[review], categories["life"].map(&:slug)
    end

    def test_tag_order_follows_post_dates_rather_than_file_names
      files = {
        "_posts/2020-01-01-late.md" => "---\ntitle: Late\ndate: 2022-01-01 10:00:00 +0100\ntags: [shared, late]\n---\n\nBody.\n",
        "_posts/2021-01-01-early.md" => "---\ntitle: Early\ntags: [shared, early]\n---\n\nBody.\n"
      }
      with_site(files) do
        tags = Site.new.load_content.tags

        assert_equal %w[shared early late], tags.keys
        assert_equal %w[late early], tags["shared"].map(&:slug)
      end
    end

    def test_site_without_posts_has_no_tags_or_categories
      with_site do
        site = Site.new.load_content

        assert_empty site.tags
        assert_empty site.categories
      end
    end

    def test_initialize_reads_the_config
      config = fixture_site.config

      assert_equal "fixture|site", config.title
      assert_equal "https://example.test", config.site_url
    end

    def test_initialize_reads_the_config_from_the_given_path
      with_site({"other.yml" => YAML.dump(fixture_config.merge("title" => "Elsewhere"))}) do
        assert_equal "Elsewhere", Site.new(config_path: "other.yml").config.title
      end
    end

    def test_initialize_raises_when_the_config_is_missing
      with_site do
        assert_raises(Errno::ENOENT) { Site.new(config_path: "missing.yml") }
      end
    end

    def test_initialize_makes_the_configured_timezone_the_process_wide_zone
      original = ENV["TZ"]
      with_site({}, config: {timezone: "America/New_York"}) do
        Site.new

        assert_equal "America/New_York", ENV["TZ"]
        assert_equal(-5 * 3600, Time.new(2021, 1, 15, 12).utc_offset)
      end
    ensure
      ENV["TZ"] = original
    end

    def test_the_timezone_defaults_to_utc
      original = ENV["TZ"]
      with_site({}, config: {timezone: nil}) do
        Site.new

        assert_equal "UTC", ENV["TZ"]
        assert_equal 0, Time.new(2021, 7, 15, 12).utc_offset
      end
    ensure
      ENV["TZ"] = original
    end

    def test_load_content_loads_every_kind_and_returns_the_site
      with_site(fixture_files) do
        site = Site.new
        result = site.load_content

        assert_same site, result
        assert_equal %w[hello-world review cafe], site.posts.map(&:slug)
        assert_equal %w[first-til second-til third-til], site.tils.map(&:slug)
        assert_equal 6, site.notes.size
        assert_equal %w[/about /archive /categories /colophon /hidden /moved /notes/ /tags /til], site.pages.map(&:permalink)
        assert_equal ["links"], site.data.keys
      end
    end

    def test_content_is_sorted_by_date_rather_than_file_name
      files = {
        "_posts/2020-01-01-late.md" => "---\ntitle: Late\ndate: 2022-01-01 10:00:00 +0100\n---\n\nBody.\n",
        "_posts/2021-01-01-early.md" => "---\ntitle: Early\n---\n\nBody.\n",
        "_til/2020/2020-01-01-late.md" => "---\ntitle: Late\ndate: 2022-01-01 10:00:00 +0100\n---\n\nBody.\n",
        "_til/2021/2021-01-01-early.md" => "---\ntitle: Early\n---\n\nBody.\n",
        "_notes/2020/2020-01-01-late.md" => "---\ndate: 2022-01-01 10:00:00 +0100\n---\n\nBody.\n",
        "_notes/2021/2021-01-01-early.md" => "---\ndate: 2021-01-01 10:00:00 +0100\n---\n\nBody.\n"
      }
      with_site(files) do
        site = Site.new.load_content

        assert_equal %w[early late], site.posts.map(&:slug)
        assert_equal %w[early late], site.tils.map(&:slug)
        assert_equal %w[early late], site.notes.map(&:slug)
      end
    end

    def test_load_content_uses_the_configured_reading_speed
      with_site({"_posts/2021-03-01-long.md" => "---\ntitle: Long\n---\n\n#{"word " * 400}\n"}) do
        assert_equal 4, Site.new.load_content.posts.first.reading_time
      end
    end

    def test_load_content_takes_a_reading_speed_override
      with_site({"_posts/2021-03-01-long.md" => "---\ntitle: Long\n---\n\n#{"word " * 400}\n"}) do
        assert_equal 2, Site.new.load_content(words_per_minute: 200).posts.first.reading_time
      end
    end

    def test_load_css_reads_the_stylesheets_and_returns_the_site
      with_site do
        site = Site.new
        result = site.load_css

        assert_same site, result
        assert_equal "/* normalize */\n\n/* base */\n\n/* components */\n", site.css
        assert_equal "/* syntax */\n", site.syntax_css
      end
    end

    def test_load_css_raises_when_a_stylesheet_is_missing
      with_site do
        File.delete("styles/base.css")

        assert_raises(Errno::ENOENT) { Site.new.load_css }
      end
    end

    def test_write_page_maps_urls_to_files_like_jekyll
      Dir.mktmpdir do |dir|
        out, = capture_io do
          site = fixture_site
          site.write_page("/about", "about", output_dir: dir)
          site.write_page("/2015/", "year", output_dir: dir)
          site.write_page("/404.html", "missing", output_dir: dir)
          site.write_page("/til/2021/03/05/first/", "til", output_dir: dir)
          site.write_page("/notes/feed.xml", "feed", output_dir: dir)
        end

        assert_equal "about", File.read(File.join(dir, "about.html"))
        assert_equal "year", File.read(File.join(dir, "2015", "index.html"))
        assert_equal "missing", File.read(File.join(dir, "404.html"))
        assert_equal "til", File.read(File.join(dir, "til/2021/03/05/first/index.html"))
        assert_equal "feed", File.read(File.join(dir, "notes", "feed.xml"))
        assert_includes out, "Generated #{File.join(dir, "about.html")}\n"
      end
    end

    def test_write_page_replaces_an_existing_file
      Dir.mktmpdir do |dir|
        capture_io do
          fixture_site.write_page("/about", "old", output_dir: dir)
          fixture_site.write_page("/about", "new", output_dir: dir)
        end

        assert_equal "new", File.read(File.join(dir, "about.html"))
      end
    end

    def test_build_writes_every_route_to_its_output_path
      built = build_fixture_site do |dir, _out|
        fixture_site.routes.each_key do |url|
          assert_path_exists Layer22::OutputPath.for(url, output_dir: dir), url
        end
      end

      assert_kind_of Site, built
    end

    def test_build_writes_the_pages_with_their_content
      build_fixture_site do |dir, _out|
        assert_match(/\A<!doctype html>/i, File.read(File.join(dir, "index.html")))
        assert_includes File.read(File.join(dir, "about.html")), "Some words about the fixture."
        assert_includes File.read(File.join(dir, "hello-world.html")), "Hello, World"
        assert_includes File.read(File.join(dir, "notes", "index.html")), "A plain note with"
        assert_includes File.read(File.join(dir, "2021", "01", "01", "index.html")), "Year — in review"
        assert_includes File.read(File.join(dir, "tags", "café", "index.html")), "Tagged: Café"
        assert_includes File.read(File.join(dir, "moved.html")), "https://elsewhere.test/landing"
        assert_includes File.read(File.join(dir, "old-review.html")), "https://example.test/review"
        assert_includes File.read(File.join(dir, "2020", "old-review.html")), "https://example.test/review"
        assert_includes File.read(File.join(dir, "404.html")), "Page not found"
      end
    end

    def test_build_writes_the_feeds_sitemap_robots_and_webfinger
      build_fixture_site do |dir, _out|
        assert_equal 3, parse_xml(File.read(File.join(dir, "feed.xml"))).xpath("//xmlns:entry").size
        assert_equal 3, parse_xml(File.read(File.join(dir, "rss.xml"))).xpath("//item").size
        assert_equal 6, parse_xml(File.read(File.join(dir, "notes", "feed.xml"))).xpath("//item").size
        assert_includes parse_xml(File.read(File.join(dir, "sitemap.xml"))).remove_namespaces!.xpath("//loc").map(&:text), "https://example.test/about"
        assert_includes File.read(File.join(dir, "robots.txt")), "Sitemap: https://example.test/sitemap.xml"
        assert_equal "acct:ada@social.example.test", JSON.parse(File.read(File.join(dir, ".well-known", "webfinger")))["subject"]
      end
    end

    def test_build_copies_the_static_assets_and_redirects
      build_fixture_site do |dir, out|
        %w[images/logo.png images/notes/wide.png images/notes/square.png site.webmanifest _redirects].each do |path|
          assert_equal File.binread(File.join(TestCase::FIXTURE_ROOT, path)), File.binread(File.join(dir, path)), path
        end
        assert_includes out, "Copied images/\n"
        assert_includes out, "Copied static assets\n"
        assert_includes out, "Copied _redirects\n"
      end
    end

    def test_build_leaves_out_static_files_the_site_does_not_have
      build_fixture_site do |dir, _out|
        %w[favicon.ico piotr-usewicz-resume.pdf assets].each { |path| refute_path_exists File.join(dir, path), path }
      end
    end

    def test_build_reports_completion_and_does_not_convert_images_when_skipping_webp
      build_fixture_site do |dir, out|
        assert_includes out, "Build complete → #{dir}\n"
        assert_empty Dir.glob("**/*.webp", base: dir)
      end
    end

    def test_build_copies_every_static_file_and_directory_the_site_has
      files = {
        "favicon.ico" => "ico", "favicon.svg" => "<svg/>", "site.webmanifest" => "{}", "piotr-usewicz-resume.pdf" => "%PDF",
        "assets/fonts/a.woff2" => "font", "images/x.png" => "png", "_redirects" => "/a /b 301\n"
      }
      with_site(files) do |dir|
        output = File.join(dir, "_site")
        capture_io { Site.new.build(output_dir: output, skip_webp: true) }

        files.except("_redirects").each { |path, contents| assert_equal contents, File.read(File.join(output, path)), path }
        assert_equal "/a /b 301\n", File.read(File.join(output, "_redirects"))
        refute_path_exists File.join(output, "favicon-16x16.png")
      end
    end

    def test_build_defaults_to_the_site_directory
      with_site do |dir|
        capture_io { Site.new.build(skip_webp: true) }

        assert_path_exists File.join(dir, "_site", "index.html")
      end
    end

    def test_build_creates_a_missing_output_directory
      with_site do |dir|
        output = File.join(dir, "nested", "deeper", "site")
        capture_io { Site.new.build(output_dir: output, skip_webp: true) }

        assert_path_exists File.join(output, "index.html")
      end
    end

    def test_build_of_an_empty_site
      with_site do |dir|
        output = File.join(dir, "_site")
        capture_io { Site.new.build(output_dir: output, skip_webp: true) }

        assert_equal %w[.well-known/webfinger 404.html feed.xml index.html notes/feed.xml robots.txt rss.xml sitemap.xml], Dir.glob("**/*", File::FNM_DOTMATCH, base: output).select { |path| File.file?(File.join(output, path)) }.sort
      end
    end

    def test_build_converts_images_to_webp_unless_skipped
      with_site({"images/logo.png" => "png"}) do |dir|
        with_path("cwebp" => %(while [ $# -gt 0 ]; do [ "$1" = -o ] && destination=$2; shift; done\necho webp > "$destination")) do
          convert = File.join(dir, "convert")
          skip = File.join(dir, "skip")
          capture_io { Site.new.build(output_dir: convert) }
          capture_io { Site.new.build(output_dir: skip, skip_webp: true) }

          assert_equal "webp\n", File.read(File.join(convert, "images", "logo.webp"))
          assert_equal "png", File.read(File.join(convert, "images", "logo.png"))
          assert_empty Dir.glob("**/*.webp", base: skip)
        end
      end
    end

    private

    # The hrefs of the prev and next links on the page at +url+, nil where absent.
    def neighbour_links(url)
      page = parse_html(fixture_site.routes.fetch(url).call)
      %w[prev next].to_h { |rel| [rel, page.at_css("a[rel=#{rel}]")&.[]("href")] }
    end

    # Files copied from the fixture site that #load_content reads.
    def fixture_files
      root = TestCase::FIXTURE_ROOT
      Dir.glob("{_posts,_til,_notes,_pages,_data}/**/*", base: root).select { |path| File.file?(File.join(root, path)) }
        .to_h { |path| [path, File.binread(File.join(root, path))] }
    end

    # Builds the fixture site into a temporary directory, yielding it and what
    # the build printed. Returns the site.
    def build_fixture_site
      Dir.mktmpdir("layer22-build") do |dir|
        site = in_fixture_site { Site.new }
        out, = in_fixture_site { capture_io { site.build(output_dir: dir, skip_webp: true) } }
        yield dir, out
        site
      end
    end
  end
end
