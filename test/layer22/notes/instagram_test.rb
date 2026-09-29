# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class InstagramKindTest < TestCase
      def test_a_reel_is_a_reel
        assert_equal "reel", Notes.instagram_kind("https://www.instagram.com/reel/Dd1n-6zthIw/")
      end

      def test_an_igtv_video_is_a_reel
        assert_equal "reel", Notes.instagram_kind("https://www.instagram.com/tv/Dd1n-6zthIw/")
      end

      def test_any_other_post_is_a_post
        assert_equal "post", Notes.instagram_kind("https://www.instagram.com/p/Dd1n-6zthIw/")
      end

      def test_accepts_the_form_with_the_username_in_the_path
        assert_equal "reel", Notes.instagram_kind("https://www.instagram.com/daniel.aagentah/reel/Dd1n-6zthIw/")
        assert_equal "post", Notes.instagram_kind("https://www.instagram.com/daniel_aagentah/p/Dd1n-6zthIw/")
      end

      def test_accepts_the_bare_host_and_any_case
        assert_equal "reel", Notes.instagram_kind("https://instagram.com/reel/Dd1n-6zthIw/")
        assert_equal "reel", Notes.instagram_kind("https://WWW.Instagram.com/reel/Dd1n-6zthIw/")
      end

      def test_ignores_a_missing_trailing_slash_and_tracking_parameters
        assert_equal "reel", Notes.instagram_kind("https://www.instagram.com/reel/Dd1n-6zthIw")
        assert_equal "reel", Notes.instagram_kind("https://www.instagram.com/reel/Dd1n-6zthIw/?igsh=abc123#top")
      end

      def test_other_instagram_pages_are_not_posts
        %w[
          https://www.instagram.com/
          https://www.instagram.com/daniel.aagentah/
          https://www.instagram.com/daniel.aagentah/reels/
          https://www.instagram.com/reel/
          https://www.instagram.com/reels/audio/123/
          https://www.instagram.com/stories/daniel.aagentah/3996276091927269936/
          https://www.instagram.com/explore/tags/webgl/
          https://www.instagram.com/reel/Dd1n-6zthIw/comments/
        ].each { |url| assert_nil Notes.instagram_kind(url), "#{url} should not be a post" }
      end

      def test_other_hosts_are_not_instagram
        %w[
          https://instagram.example.com/reel/Dd1n-6zthIw/
          https://notinstagram.com/reel/Dd1n-6zthIw/
          https://www.instagram.com.example.com/reel/Dd1n-6zthIw/
          https://example.com/instagram.com/reel/Dd1n-6zthIw/
        ].each { |url| assert_nil Notes.instagram_kind(url), "#{url} should not be a post" }
      end
    end

    class InstagramMetadataTest < TestCase
      REEL = "https://www.instagram.com/reel/Dd1n-6zthIw/"
      OEMBED = {
        "title" => "Hello friends,\n\nI am thrilled to announce NOMIAD.",
        "author_name" => "daniel.aagentah",
        "provider_name" => "Instagram",
        "thumbnail_url" => "https://scontent.cdninstagram.com/v/thumb.jpg?x=1&y=2",
        "html" => "<blockquote class=\"instagram-media\"></blockquote>"
      }.freeze

      def test_asks_the_oembed_endpoint_about_the_post
        requested = with_oembed { |urls| Notes.instagram_metadata(REEL) && urls }

        assert_equal ["https://www.instagram.com/api/v1/oembed/?url=#{CGI.escape(REEL)}"], requested
      end

      def test_passes_the_url_as_pasted
        url = "#{REEL}?igsh=abc123"

        requested = with_oembed { |urls| Notes.instagram_metadata(url) && urls }

        assert_includes requested.first, "url=https%3A%2F%2Fwww.instagram.com%2Freel%2FDd1n-6zthIw%2F%3Figsh%3Dabc123"
      end

      def test_returns_the_kind_author_caption_and_thumbnail
        metadata = with_oembed { Notes.instagram_metadata(REEL) }

        assert_equal(
          {
            "site" => "Instagram",
            "instagram" => "reel",
            "author" => "daniel.aagentah",
            "description" => "Hello friends, I am thrilled to announce NOMIAD.",
            "image_urls" => ["https://scontent.cdninstagram.com/v/thumb.jpg?x=1&y=2"]
          },
          metadata
        )
      end

      def test_a_photo_post_is_a_post
        metadata = with_oembed { Notes.instagram_metadata("https://www.instagram.com/p/Dd1n-6zthIw/") }

        assert_equal "post", metadata["instagram"]
      end

      def test_a_long_caption_is_cut_between_words
        caption = "word " * 100

        metadata = with_oembed(OEMBED.merge("title" => caption)) { Notes.instagram_metadata(REEL) }

        assert_operator metadata["description"].length, :<=, Notes::DESCRIPTION_LENGTH
        assert metadata["description"].end_with?("word…")
      end

      def test_missing_fields_are_empty
        metadata = with_oembed({"author_name" => "daniel.aagentah"}) { Notes.instagram_metadata(REEL) }

        assert_equal "", metadata["description"]
        assert_equal [], metadata["image_urls"]
      end

      def test_reads_a_utf_8_body
        data = OEMBED.merge("title" => "Café ☕ — “Live” 🎉")

        metadata = with_oembed(data) { Notes.instagram_metadata(REEL) }

        assert_equal "Café ☕ — “Live” 🎉", metadata["description"]
        assert_equal Encoding::UTF_8, metadata["description"].encoding
      end

      def test_a_failed_request_raises
        failing = ->(_url, **) { raise "404 Not Found" }

        error = Notes.stub(:get, failing) { assert_raises(RuntimeError) { Notes.instagram_metadata(REEL) } }

        assert_equal "404 Not Found", error.message
      end

      def test_a_response_that_is_not_json_raises_naming_its_type
        login = ->(url, **) { ["<html>Log in</html>".b, url, "text/html"] }

        error = Notes.stub(:get, login) { assert_raises(RuntimeError) { Notes.instagram_metadata(REEL) } }

        assert_equal "not JSON (text/html)", error.message
      end

      private

      # Runs the block with Notes.get answering with +data+ as an oEmbed
      # response, yielding the URLs requested so far.
      def with_oembed(data = OEMBED)
        requested = []
        fake = lambda do |url, **|
          requested << url
          [JSON.generate(data).b, url, "application/json; charset=utf-8"]
        end
        Notes.stub(:get, fake) { yield requested }
      end
    end

    class FetchLinkInstagramTest < TestCase
      REEL = "https://www.instagram.com/reel/Dd1n-6zthIw/"
      THUMB = "https://scontent.cdninstagram.com/v/thumb.jpg"
      OEMBED = {"title" => "A caption", "author_name" => "ada", "thumbnail_url" => THUMB}.freeze

      def test_records_the_kind_caption_and_author_and_downloads_the_thumbnail
        link = with_site { with_instagram { Notes.fetch_link(REEL, "2026-09-29-101530") } }

        assert_equal(
          {
            "url" => REEL,
            "site" => "Instagram",
            "instagram" => "reel",
            "author" => "ada",
            "description" => "A caption",
            "image" => "/images/notes/2026-09-29-101530.jpg"
          },
          link
        )
        assert_equal %w[url site instagram author description image], link.keys
      end

      def test_saves_the_thumbnail
        with_site do
          with_instagram { Notes.fetch_link(REEL, "note") }

          assert_equal "thumbnail bytes", File.binread("images/notes/note.jpg")
        end
      end

      def test_a_post_without_a_caption_or_thumbnail_has_neither
        oembed = {"author_name" => "ada"}

        with_site do
          link = with_instagram(oembed) { Notes.fetch_link(REEL, "note") }

          assert_equal({"url" => REEL, "site" => "Instagram", "instagram" => "reel", "author" => "ada"}, link)
          refute Dir.exist?("images")
        end
      end

      def test_keeps_the_post_when_the_thumbnail_cannot_be_downloaded
        fake = lambda do |url, **|
          raise "403 Forbidden" if url == THUMB

          [JSON.generate(OEMBED).b, url, "application/json"]
        end

        link = nil
        _, stderr = capture_io { with_site { link = Notes.stub(:get, fake) { Notes.fetch_link(REEL, "note") } } }

        assert_equal "A caption", link["description"]
        refute link.key?("image")
        assert_equal "Could not download a thumbnail:\n  #{THUMB}: 403 Forbidden\n", stderr
      end

      def test_a_post_that_cannot_be_read_gives_the_bare_link_and_a_warning
        failing = ->(_url, **) { raise "404 Not Found" }

        link = nil
        _, stderr = capture_io { link = Notes.stub(:get, failing) { Notes.fetch_link(REEL, "note") } }

        assert_equal({"url" => REEL, "site" => "instagram.com"}, link)
        assert_equal "Could not fetch #{REEL}: 404 Not Found\n", stderr
      end

      def test_other_instagram_pages_are_read_as_pages
        pages = []
        page = lambda do |url|
          pages << url
          {"title" => "ada (@ada) • Instagram photos and videos"}
        end
        instagram = ->(_url) { flunk "should not ask oEmbed" }

        link = Notes.stub(:page_metadata, page) do
          Notes.stub(:instagram_metadata, instagram) { Notes.fetch_link("https://www.instagram.com/ada/", "note") }
        end

        assert_equal ["https://www.instagram.com/ada/"], pages
        assert_equal "ada (@ada) • Instagram photos and videos", link["title"]
        refute link.key?("instagram")
      end

      private

      # Runs the block with Notes.get answering oEmbed with +oembed+ and the thumbnail with a JPEG.
      def with_instagram(oembed = OEMBED, &)
        fake = lambda do |url, **|
          (url == THUMB) ? ["thumbnail bytes".b, url, "image/jpeg"] : [JSON.generate(oembed).b, url, "application/json"]
        end
        Notes.stub(:get, fake, &)
      end
    end
  end
end
