# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class FetchLinkTest < ServerTestCase
      def test_merges_the_page_metadata_and_a_downloaded_thumbnail
        @server.serve("/post", head(<<~HTML))
          <title>Fallback</title>
          <meta property="og:title" content="A Post">
          <meta property="og:site_name" content="Example Blog">
          <meta property="og:description" content="What it is about.">
          <meta property="og:image" content="/cover.png">
        HTML
        @server.serve("/cover.png", png, type: "image/png")

        with_site do
          link = Notes.fetch_link(@server.url("/post"), "2026-09-28-101530")

          assert_equal(
            {
              "url" => @server.url("/post"),
              "site" => "Example Blog",
              "title" => "A Post",
              "description" => "What it is about.",
              "image" => "/images/notes/2026-09-28-101530.png"
            },
            link
          )
          assert_equal png, File.binread("images/notes/2026-09-28-101530.png")
        end
      end

      def test_keys_are_in_the_order_they_are_written_to_the_note
        @server.serve("/post", head(<<~HTML))
          <meta property="og:title" content="A Post">
          <meta property="og:site_name" content="Example Blog">
          <meta property="og:description" content="What it is about.">
          <meta property="og:image" content="/cover.png">
        HTML
        @server.serve("/cover.png", png, type: "image/png")

        with_site do
          assert_equal %w[url site title description image], Notes.fetch_link(@server.url("/post"), "note").keys
        end
      end

      def test_the_site_is_the_host_when_the_page_has_no_site_name
        @server.serve("/post", head(%(<title>A Post</title>)))

        assert_equal "127.0.0.1", Notes.fetch_link(@server.url("/post"), "note")["site"]
      end

      def test_omits_blank_metadata
        @server.serve("/post", head(<<~HTML))
          <meta property="og:title" content="   ">
          <meta property="og:description" content="">
        HTML

        assert_equal(
          {"url" => @server.url("/post"), "site" => "127.0.0.1"},
          Notes.fetch_link(@server.url("/post"), "note")
        )
      end

      def test_a_page_without_an_image_downloads_nothing
        @server.serve("/post", head(%(<title>A Post</title>)))

        with_site do
          link = Notes.fetch_link(@server.url("/post"), "note")

          refute link.key?("image")
          refute Dir.exist?("images")
        end
        assert_equal ["/post"], @server.requests.map(&:path)
      end

      def test_uses_the_url_it_was_redirected_to_for_relative_images
        @server.redirect("/short", "/articles/post")
        @server.serve("/articles/post", head(%(<meta property="og:image" content="cover.png">)))
        @server.serve("/articles/cover.png", png, type: "image/png")

        with_site do
          link = Notes.fetch_link(@server.url("/short"), "note")

          assert_equal @server.url("/short"), link["url"]
          assert_equal "/images/notes/note.png", link["image"]
        end
      end

      def test_keeps_the_metadata_when_the_thumbnail_cannot_be_downloaded
        @server.serve("/post", head(<<~HTML))
          <meta property="og:title" content="A Post">
          <meta property="og:image" content="/logo.svg">
        HTML
        @server.serve("/logo.svg", "<svg/>", type: "image/svg+xml")

        with_site do
          link = nil
          _, stderr = capture_io { link = Notes.fetch_link(@server.url("/post"), "note") }

          assert_equal "A Post", link["title"]
          refute link.key?("image")
          assert_equal "Could not download a thumbnail:\n  #{@server.url("/logo.svg")}: image/svg+xml is not a supported image\n", stderr
        end
      end

      def test_keeps_the_metadata_when_the_thumbnail_is_missing
        @server.serve("/post", head(<<~HTML))
          <meta property="og:title" content="A Post">
          <meta property="og:image" content="/gone.png">
        HTML

        with_site do
          link = nil
          _, stderr = capture_io { link = Notes.fetch_link(@server.url("/post"), "note") }

          assert_equal "A Post", link["title"]
          refute link.key?("image")
          assert_includes stderr, "  #{@server.url("/gone.png")}: 404 Not Found\n"
        end
      end

      def test_a_page_with_bytes_invalid_in_its_charset_still_gives_its_metadata
        @server.serve("/post", "<title>Caf\xFF</title>".b, type: "text/html; charset=utf-8")

        link = nil
        _, stderr = capture_io { link = Notes.fetch_link(@server.url("/post"), "note") }

        assert_equal "Caf�", link["title"]
        assert_empty stderr
      end

      def test_a_missing_page_gives_the_bare_link_and_a_warning
        link = nil
        _, stderr = capture_io { link = Notes.fetch_link(@server.url("/nothing"), "note") }

        assert_equal({"url" => @server.url("/nothing"), "site" => "127.0.0.1"}, link)
        assert_equal "Could not fetch #{@server.url("/nothing")}: 404 Not Found\n", stderr
      end

      def test_a_page_that_is_not_html_gives_the_bare_link_and_a_warning
        @server.serve("/paper.pdf", "%PDF-1.7", type: "application/pdf")

        link = nil
        _, stderr = capture_io { link = Notes.fetch_link(@server.url("/paper.pdf"), "note") }

        assert_equal({"url" => @server.url("/paper.pdf"), "site" => "127.0.0.1"}, link)
        assert_equal "Could not fetch #{@server.url("/paper.pdf")}: not an HTML page (application/pdf)\n", stderr
      end

      def test_a_redirect_loop_gives_the_bare_link_and_a_warning
        @server.redirect("/loop", "/loop")

        link = nil
        _, stderr = capture_io { link = Notes.fetch_link(@server.url("/loop"), "note") }

        assert_equal({"url" => @server.url("/loop"), "site" => "127.0.0.1"}, link)
        assert_equal "Could not fetch #{@server.url("/loop")}: too many redirects\n", stderr
      end

      def test_a_refused_connection_gives_the_bare_link_and_a_warning
        url = "http://127.0.0.1:9/post"

        link = nil
        stderr = nil
        with_refused_connections { _, stderr = capture_io { link = Notes.fetch_link(url, "note") } }

        assert_equal({"url" => url, "site" => "127.0.0.1"}, link)
        assert_equal 1, stderr.lines.size
        assert_match(/\ACould not fetch #{Regexp.escape(url)}: Connection refused/, stderr)
      end

      def test_a_url_that_does_not_parse_still_gives_a_link_and_a_warning
        link = nil
        _, stderr = capture_io { link = Notes.fetch_link("http://[::1", "note") }

        assert_equal({"url" => "http://[::1"}, link)
        assert_equal 1, stderr.lines.size
        assert_match(/\ACould not fetch http:\/\/\[::1: /, stderr)
      end

      def test_strips_www_from_the_site
        page = ->(_url) { {"title" => "A Post"} }

        link = Notes.stub(:page_metadata, page) { Notes.fetch_link("https://www.example.com/post", "note") }

        assert_equal({"url" => "https://www.example.com/post", "site" => "example.com", "title" => "A Post"}, link)
      end

      def test_hands_the_image_candidates_and_basename_to_the_downloader
        page = ->(_url) { {"title" => "A Post", "image_urls" => ["https://cdn.example.com/a.png"]} }
        downloads = []
        downloader = lambda do |urls, basename|
          downloads << [urls, basename]
          "/images/notes/#{basename}.png"
        end

        link = Notes.stub(:page_metadata, page) do
          Notes.stub(:download_image, downloader) { Notes.fetch_link("https://example.com/post", "2026-09-28-101530") }
        end

        assert_equal [[["https://cdn.example.com/a.png"], "2026-09-28-101530"]], downloads
        assert_equal "/images/notes/2026-09-28-101530.png", link["image"]
        refute link.key?("image_urls")
      end

      def test_does_not_set_an_image_when_the_downloader_finds_none
        page = ->(_url) { {"image_urls" => ["https://cdn.example.com/a.png"]} }

        link = Notes.stub(:page_metadata, page) do
          Notes.stub(:download_image, ->(_urls, _basename) {}) { Notes.fetch_link("https://example.com/post", "note") }
        end

        assert_equal({"url" => "https://example.com/post", "site" => "example.com"}, link)
      end

      def test_does_not_call_the_downloader_without_image_candidates
        downloader = ->(_urls, _basename) { flunk "should not download" }

        [{"title" => "A Post"}, {"title" => "A Post", "image_urls" => []}, {"title" => "A Post", "image_urls" => nil}].each do |metadata|
          link = Notes.stub(:page_metadata, ->(_url) { metadata.dup }) do
            Notes.stub(:download_image, downloader) { Notes.fetch_link("https://example.com/post", "note") }
          end

          assert_equal "A Post", link["title"]
        end
      end

      private

      def head(markup)
        "<!DOCTYPE html><html><head>#{markup}</head><body></body></html>"
      end
    end

    class FetchLinkYoutubeTest < TestCase
      ID = "dQw4w9WgXcQ"
      OEMBED = {"title" => "Never Gonna Give You Up", "author_name" => "Rick Astley", "provider_name" => "YouTube"}.freeze

      def test_records_the_video_id_instead_of_a_thumbnail
        link = with_oembed { Notes.fetch_link("https://youtu.be/#{ID}", "note") }

        assert_equal(
          {
            "url" => "https://youtu.be/#{ID}",
            "site" => "YouTube",
            "youtube" => ID,
            "title" => "Never Gonna Give You Up",
            "author" => "Rick Astley"
          },
          link
        )
        assert_equal %w[url site youtube title author], link.keys
      end

      def test_only_asks_the_oembed_endpoint
        requested = []

        with_site do
          with_oembed(requested:) { Notes.fetch_link("https://www.youtube.com/watch?v=#{ID}", "note") }

          refute Dir.exist?("images")
        end

        assert_equal 1, requested.size
        assert_match(%r{\Ahttps://www\.youtube\.com/oembed\?}, requested.first)
      end

      def test_the_site_is_the_host_when_oembed_names_none
        link = with_oembed(OEMBED.except("provider_name")) { Notes.fetch_link("https://www.youtube.com/watch?v=#{ID}", "note") }

        assert_equal "youtube.com", link["site"]
      end

      def test_a_video_url_without_a_valid_id_has_no_youtube_key
        link = with_oembed { Notes.fetch_link("https://www.youtube.com/watch?v=short", "note") }

        refute link.key?("youtube")
        assert_equal "Never Gonna Give You Up", link["title"]
      end

      def test_keeps_the_video_id_when_oembed_fails
        failing = ->(_url, **) { raise "401 Unauthorized" }

        link = nil
        _, stderr = capture_io do
          link = Notes.stub(:get, failing) { Notes.fetch_link("https://youtu.be/#{ID}", "note") }
        end

        assert_equal({"url" => "https://youtu.be/#{ID}", "site" => "youtu.be", "youtube" => ID}, link)
        assert_equal "Could not fetch https://youtu.be/#{ID}: 401 Unauthorized\n", stderr
      end

      private

      def with_oembed(data = OEMBED, requested: [])
        fake = lambda do |url, **|
          requested << url
          [JSON.generate(data).b, url, "application/json"]
        end
        Notes.stub(:get, fake) { yield }
      end
    end

    class FetchLinkBlueskyTest < TestCase
      POST_URL = "https://bsky.app/profile/ada.example.com/post/3kabc"
      THUMB = "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:abc/bafkrei"
      THREAD = {
        "$type" => "app.bsky.feed.defs#threadViewPost",
        "post" => {
          "author" => {"handle" => "ada.example.com", "displayName" => "Ada"},
          "record" => {"text" => "Hello world", "createdAt" => "2021-05-06T22:30:00.000Z", "langs" => ["en"]},
          "embed" => {"$type" => "app.bsky.embed.images#view", "images" => [{"thumb" => THUMB, "alt" => "A pic"}]}
        }
      }.freeze

      def test_records_the_post_and_downloads_its_first_image
        link = with_site { with_bluesky { Notes.fetch_link(POST_URL, "2026-09-29-101530") } }

        assert_equal(
          {
            "url" => POST_URL,
            "site" => "Bluesky",
            "author" => "Ada",
            "bluesky" => {
              "handle" => "ada.example.com",
              "date" => "2021-05-06T22:30:00Z",
              "lang" => "en",
              "text" => "Hello world",
              "alt" => "A pic"
            },
            "image" => "/images/notes/2026-09-29-101530.png"
          },
          link
        )
        assert_equal %w[url site author bluesky image], link.keys
      end

      def test_saves_the_image
        with_site do
          with_bluesky { Notes.fetch_link(POST_URL, "note") }

          assert_equal png, File.binread("images/notes/note.png")
        end
      end

      def test_a_post_without_pictures_downloads_nothing
        thread = THREAD.merge("post" => THREAD["post"].except("embed"))

        with_site do
          link = with_bluesky(thread) { Notes.fetch_link(POST_URL, "note") }

          refute link.key?("image")
          refute Dir.exist?("images")
        end
      end

      def test_a_post_without_a_display_name_has_no_author
        author = {"handle" => "ada.example.com"}
        thread = THREAD.merge("post" => THREAD["post"].merge("author" => author))

        link = with_site { with_bluesky(thread) { Notes.fetch_link(POST_URL, "note") } }

        refute link.key?("author")
      end

      def test_keeps_the_post_when_the_image_cannot_be_downloaded
        fake = lambda do |url, **|
          raise "404 Not Found" if url == THUMB

          [JSON.generate({"thread" => THREAD}).b, url, "application/json"]
        end

        link = nil
        _, stderr = capture_io { with_site { link = Notes.stub(:get, fake) { Notes.fetch_link(POST_URL, "note") } } }

        assert_equal "Hello world", link["bluesky"]["text"]
        refute link.key?("image")
        assert_equal "Could not download a thumbnail:\n  #{THUMB}: 404 Not Found\n", stderr
      end

      def test_a_post_that_cannot_be_read_gives_the_bare_link_and_a_warning
        failing = ->(_url, **) { raise "400 Bad Request" }

        link = nil
        _, stderr = capture_io { link = Notes.stub(:get, failing) { Notes.fetch_link(POST_URL, "note") } }

        assert_equal({"url" => POST_URL, "site" => "bsky.app"}, link)
        assert_equal "Could not fetch #{POST_URL}: 400 Bad Request\n", stderr
      end

      def test_a_post_that_is_gone_gives_the_bare_link_and_a_warning
        thread = {"$type" => "app.bsky.feed.defs#notFoundPost", "uri" => "at://x", "notFound" => true}

        link = nil
        _, stderr = capture_io { link = with_bluesky(thread) { Notes.fetch_link(POST_URL, "note") } }

        assert_equal({"url" => POST_URL, "site" => "bsky.app"}, link)
        assert_equal "Could not fetch #{POST_URL}: the post is not available (app.bsky.feed.defs#notFoundPost)\n", stderr
      end

      def test_other_bsky_app_pages_are_read_as_pages
        pages = []
        page = lambda do |url|
          pages << url
          {"title" => "Ada (@ada.example.com)"}
        end
        bluesky = ->(_url) { flunk "should not ask the API" }

        link = Notes.stub(:page_metadata, page) do
          Notes.stub(:bluesky_metadata, bluesky) { Notes.fetch_link("https://bsky.app/profile/ada.example.com", "note") }
        end

        assert_equal ["https://bsky.app/profile/ada.example.com"], pages
        assert_equal({"url" => "https://bsky.app/profile/ada.example.com", "site" => "bsky.app", "title" => "Ada (@ada.example.com)"}, link)
      end

      private

      # Runs the block with Notes.get answering the API with +thread+ and the image with a PNG.
      def with_bluesky(thread = THREAD, &)
        fake = lambda do |url, **|
          (url == THUMB) ? [png, url, "image/png"] : [JSON.generate({"thread" => thread}).b, url, "application/json"]
        end
        Notes.stub(:get, fake, &)
      end
    end
  end
end
