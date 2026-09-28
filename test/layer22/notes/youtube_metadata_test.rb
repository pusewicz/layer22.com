# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class YoutubeMetadataTest < TestCase
      VIDEO = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=5s"
      OEMBED = {"title" => "Never Gonna Give You Up", "author_name" => "Rick Astley", "provider_name" => "YouTube"}.freeze

      def test_asks_the_oembed_endpoint_about_the_video
        requested = with_oembed do |urls|
          Notes.youtube_metadata(VIDEO)
          urls
        end

        assert_equal ["https://www.youtube.com/oembed?format=json&url=#{CGI.escape(VIDEO)}"], requested
      end

      def test_escapes_the_video_url_in_the_query
        requested = with_oembed do |urls|
          Notes.youtube_metadata(VIDEO)
          urls
        end

        assert_includes requested.first, "url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DdQw4w9WgXcQ%26t%3D5s"
      end

      def test_returns_the_title_site_and_author
        metadata = with_oembed { Notes.youtube_metadata(VIDEO) }

        assert_equal({"title" => "Never Gonna Give You Up", "site" => "YouTube", "author" => "Rick Astley"}, metadata)
      end

      def test_reads_a_utf_8_body
        data = OEMBED.merge("title" => "Café ☕ — “Live”", "author_name" => "Zażółć")

        metadata = with_oembed(data) { Notes.youtube_metadata(VIDEO) }

        assert_equal "Café ☕ — “Live”", metadata["title"]
        assert_equal "Zażółć", metadata["author"]
        assert_equal Encoding::UTF_8, metadata["title"].encoding
      end

      def test_reads_a_body_already_tagged_as_utf_8
        data = OEMBED.merge("title" => "Café ☕")
        tagged = ->(url, **) { [JSON.generate(data), url, "application/json"] }

        metadata = Notes.stub(:get, tagged) { Notes.youtube_metadata(VIDEO) }

        assert_equal "Café ☕", metadata["title"]
      end

      def test_missing_fields_are_nil
        metadata = with_oembed({"title" => "Only a title"}) { Notes.youtube_metadata(VIDEO) }

        assert_equal({"title" => "Only a title", "site" => nil, "author" => nil}, metadata)
      end

      def test_has_no_image_candidates
        metadata = with_oembed(OEMBED.merge("thumbnail_url" => "https://i.ytimg.com/vi/x/hq.jpg")) { Notes.youtube_metadata(VIDEO) }

        refute metadata.key?("image_urls")
      end

      def test_a_failed_request_raises
        failing = ->(_url, **) { raise "404 Not Found" }

        error = Notes.stub(:get, failing) { assert_raises(RuntimeError) { Notes.youtube_metadata(VIDEO) } }

        assert_equal "404 Not Found", error.message
      end

      def test_a_response_that_is_not_json_raises
        html = ->(url, **) { ["<html>consent</html>".b, url, "text/html"] }

        Notes.stub(:get, html) { assert_raises(JSON::ParserError) { Notes.youtube_metadata(VIDEO) } }
      end

      private

      # Runs the block with Notes.get answering with +data+ as an oEmbed
      # response, yielding the URLs requested so far.
      def with_oembed(data = OEMBED)
        requested = []
        fake = lambda do |url, **|
          requested << url
          [JSON.generate(data).b, url, "application/json"]
        end
        Notes.stub(:get, fake) { yield requested }
      end
    end
  end
end
