# frozen_string_literal: true

require "test_helper"
require "layer22/dev_server"

module Layer22
  class DevServerTest < TestCase
    def test_home_page_is_served_at_the_root
      serving_fixture_site do |server|
        response = server.get("/")

        assert_equal 200, response.status
        assert_equal "text/html", response.headers["content-type"]
        assert_match(/\A<!doctype html>/i, response.body)
        assert_equal "fixture|site · A fixture tagline", parse_html(response.body).at_css("title").text
      end
    end

    def test_a_page_is_served_with_and_without_the_html_extension
      serving_fixture_site do |server|
        with_extension = server.get("/about.html")

        assert_equal 200, with_extension.status
        assert_equal "About · fixture|site", parse_html(with_extension.body).at_css("title").text
        assert_equal with_extension.body, server.get("/about").body
      end
    end

    def test_a_directory_page_is_served_with_and_without_the_trailing_slash
      serving_fixture_site do |server|
        %w[/notes /notes/ /2021 /2021/ /2021/06/01 /2021/06/01/ /tags/ruby /tags/ruby/].each_slice(2) do |bare, slashed|
          assert_equal 200, server.get(bare).status, bare
          assert_equal server.get(slashed).body, server.get(bare).body, bare
        end
      end
    end

    def test_the_year_archive_is_served_at_2021_and_2021_slash
      serving_fixture_site do |server|
        %w[/2021 /2021/].each do |path|
          page = parse_html(server.get(path).body)

          assert_equal "2021", page.at_css("h1").text, path
          assert_equal %w[/cafe /review], page.css(".post-row a").map { |a| a["href"] }, path
        end
      end
    end

    def test_a_page_without_a_trailing_slash_is_served_when_its_route_has_one
      serving_fixture_site do |server|
        assert_includes parse_html(server.get("/til").body).text, "Third TIL"
        assert_includes parse_html(server.get("/til/").body).text, "Third TIL"
        assert_includes parse_html(server.get("/til/2021/03/05/first-til").body).at_css("h1").text, "First TIL"
      end
    end

    def test_a_route_with_an_html_extension_is_served
      serving_fixture_site do |server|
        assert_equal 200, server.get("/2020/old-review.html").status
        assert_includes server.get("/2020/old-review.html").body, "https://example.test/review"
      end
    end

    def test_the_query_string_is_ignored
      serving_fixture_site do |server|
        assert_equal server.get("/about").body, server.get("/about?ref=feed&page=2").body
      end
    end

    def test_the_atom_feed_is_served
      serving_fixture_site do |server|
        response = server.get("/feed.xml")

        assert_equal 200, response.status
        assert_equal "application/atom+xml", response.headers["content-type"]
        assert_equal 3, parse_xml(response.body).remove_namespaces!.xpath("/feed/entry").size
      end
    end

    def test_the_post_and_note_rss_feeds_are_served
      serving_fixture_site do |server|
        {"/rss.xml" => 3, "/notes/feed.xml" => 8}.each do |path, items|
          response = server.get(path)

          assert_equal 200, response.status, path
          assert_equal "application/rss+xml", response.headers["content-type"], path
          assert_equal items, parse_xml(response.body).xpath("/rss/channel/item").size, path
        end
      end
    end

    def test_the_sitemap_is_served
      serving_fixture_site do |server|
        response = server.get("/sitemap.xml")

        assert_equal 200, response.status
        assert_equal "application/xml", response.headers["content-type"]
        locs = parse_xml(response.body).remove_namespaces!.xpath("/urlset/url/loc").map(&:text)
        assert_includes locs, "https://example.test/about"
        refute_includes locs, "https://example.test/hidden"
      end
    end

    def test_static_files_are_served_without_caching
      serving_fixture_site do |server|
        %w[/images/logo.png /images/notes/wide.png /site.webmanifest].each do |path|
          response = server.get(path)

          assert_equal 200, response.status, path
          assert_equal "no-cache", response.headers["cache-control"], path
          assert_equal File.binread(File.join(TestCase::FIXTURE_ROOT, path)), response.body, path
        end
      end
    end

    def test_static_images_have_their_media_type
      serving_fixture_site do |server|
        assert_equal "image/png", server.get("/images/notes/wide.png").headers["content-type"]
      end
    end

    def test_a_missing_static_file_is_not_found
      serving_fixture_site do |server|
        assert_equal 404, server.get("/images/missing.png").status
        assert_equal 404, server.get("/favicon.ico").status
      end
    end

    def test_an_unknown_path_gets_the_not_found_page
      serving_fixture_site do |server|
        response = server.get("/nope")

        assert_equal 404, response.status
        assert_equal "text/html", response.headers["content-type"]
        assert_includes parse_html(response.body).text, "Page not found"
        assert_includes parse_html(response.body).at_css("title").text, "fixture|site"
      end
    end

    def test_unknown_paths_with_an_extension_or_depth_are_not_found
      serving_fixture_site do |server|
        %w[/nope.html /hello-world/extra /2021/13/ /tags/unknown/ /feed.xml/more].each do |path|
          assert_equal 404, server.get(path).status, path
        end
      end
    end

    def test_hidden_pages_are_still_served
      serving_fixture_site do |server|
        assert_equal 200, server.get("/hidden").status
      end
    end

    def test_content_is_read_again_on_every_request
      with_site do
        server = Rack::MockRequest.new(DevServer.new)

        assert_equal 404, server.get("/new-post").status
        assert_equal 0, feed_entries(server).size

        write_file("_posts/2021-03-01-new-post.md", "---\ntitle: Brand new\ntags: [fresh]\n---\n\nFirst draft.\n")
        page = server.get("/new-post")

        assert_equal 200, page.status
        assert_equal "Brand new · fixture|site", parse_html(page.body).at_css("title").text
        assert_includes parse_html(page.body).text, "First draft."
        assert_equal ["Brand new"], feed_entries(server)
        assert_equal 200, server.get("/tags/fresh/").status
        assert_equal 200, server.get("/2021/03/").status

        write_file("_posts/2021-03-01-new-post.md", "---\ntitle: Renamed\n---\n\nSecond draft.\n")

        assert_includes parse_html(server.get("/new-post").body).text, "Second draft."
        assert_equal ["Renamed"], feed_entries(server)
        assert_equal 404, server.get("/tags/fresh/").status

        File.delete("_posts/2021-03-01-new-post.md")

        assert_equal 404, server.get("/new-post").status
        assert_equal 0, feed_entries(server).size
      end
    end

    def test_new_pages_and_notes_and_stylesheets_are_picked_up
      with_site do
        server = Rack::MockRequest.new(DevServer.new)
        assert_equal 404, server.get("/colophon").status

        write_file("_pages/colophon.md", "---\ntitle: Colophon\npermalink: /colophon\n---\n\nMade by hand.\n")
        write_file("_notes/2021/05/2021-05-01-hello.md", "---\ndate: 2021-05-01 09:30:00 +0200\n---\n\nA fresh note.\n")
        write_file("styles/base.css", "body { color: rebeccapurple; }\n")

        assert_includes parse_html(server.get("/colophon").body).text, "Made by hand."
        assert_includes server.get("/notes/2021/05/01/hello/").body, "A fresh note."
        assert_includes server.get("/colophon").body, "color: rebeccapurple"
      end
    end

    def test_the_config_is_read_again_on_every_request
      with_site do
        server = Rack::MockRequest.new(DevServer.new)
        assert_equal "fixture|site", feed_title(server)

        write_file("site.yml", YAML.dump(fixture_config.merge("title" => "Renamed site")))

        assert_equal "Renamed site", feed_title(server)
      end
    end

    def test_the_config_path_is_used
      with_site({"other.yml" => YAML.dump(fixture_config.merge("title" => "Elsewhere"))}) do
        server = Rack::MockRequest.new(DevServer.new(config_path: "other.yml"))

        assert_equal "Elsewhere", feed_title(server)
      end
    end

    def test_a_page_that_cannot_render_raises_and_later_requests_still_work
      with_site({"_pages/odd.md" => "---\ntitle: Odd\npermalink: /odd\nlayout: bogus\n---\n"}) do
        server = Rack::MockRequest.new(DevServer.new)

        assert_raises(ArgumentError) { server.get("/odd") }
        assert_equal 200, server.get("/").status
      end
    end

    def test_code_is_reloaded_at_the_start_of_every_request
      reloads = 0
      Layer22.stub(:reload!, -> { reloads += 1 }) do
        serving_fixture_site do |server|
          server.get("/")
          server.get("/nope")
          server.get("/feed.xml")
        end
      end

      assert_equal 3, reloads
    end

    def test_static_files_are_served_before_the_dev_server_runs
      reloads = 0
      Layer22.stub(:reload!, -> { reloads += 1 }) do
        serving_fixture_site { |server| server.get("/images/logo.png") }
      end

      assert_equal 0, reloads
    end

    private

    # Runs the block with a client for the dev server the rake task builds, in
    # the fixture site's directory. Rack::Static resolves its root there.
    def serving_fixture_site
      in_fixture_site { yield Rack::MockRequest.new(DevServer.build) }
    end

    def feed_entries(server)
      parse_xml(server.get("/feed.xml").body).remove_namespaces!.xpath("/feed/entry/title").map(&:text)
    end

    def feed_title(server)
      parse_xml(server.get("/feed.xml").body).remove_namespaces!.at_xpath("/feed/title").text
    end
  end
end
