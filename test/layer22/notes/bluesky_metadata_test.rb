# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class BlueskyMetadataTest < TestCase
      POST_URL = "https://bsky.app/profile/ada.example.com/post/3kabc"
      THREAD = {
        "$type" => "app.bsky.feed.defs#threadViewPost",
        "post" => {
          "author" => {"handle" => "ada.example.com", "displayName" => "Ada"},
          "record" => {"text" => "Hello world", "createdAt" => "2021-05-06T22:30:00.123Z", "langs" => %w[en es]}
        }
      }.freeze

      def test_asks_the_public_appview_for_the_post_alone
        requested = with_thread { |urls| Notes.bluesky_metadata(POST_URL) && urls }

        assert_equal [
          "https://public.api.bsky.app/xrpc/app.bsky.feed.getPostThread" \
          "?uri=at%3A%2F%2Fada.example.com%2Fapp.bsky.feed.post%2F3kabc&depth=0&parentHeight=0"
        ], requested
      end

      def test_asks_about_a_post_by_did
        url = "https://bsky.app/profile/did:plc:abc123/post/3kabc"

        requested = with_thread { |urls| Notes.bluesky_metadata(url) && urls }

        assert_includes requested.first, "uri=at%3A%2F%2Fdid%3Aplc%3Aabc123%2Fapp.bsky.feed.post%2F3kabc&"
      end

      def test_returns_the_site_author_and_post
        metadata = with_thread { Notes.bluesky_metadata(POST_URL) }

        assert_equal(
          {
            "site" => "Bluesky",
            "author" => "Ada",
            "bluesky" => {
              "handle" => "ada.example.com",
              "date" => "2021-05-06T22:30:00Z",
              "lang" => "en",
              "text" => "Hello world"
            },
            "image_urls" => []
          },
          metadata
        )
      end

      def test_post_details_are_in_the_order_they_are_written_to_the_note
        thread = with_embed(
          {"$type" => "app.bsky.embed.images#view", "images" => [{"thumb" => "https://cdn.example/1.jpg", "alt" => "Pic"}]},
          "record" => THREAD["post"]["record"].merge(
            "facets" => [{"index" => {"byteStart" => 0, "byteEnd" => 5}, "features" => [{"$type" => "app.bsky.richtext.facet#tag", "tag" => "hello"}]}]
          )
        )

        metadata = with_thread(thread) { Notes.bluesky_metadata(POST_URL) }

        assert_equal %w[handle date lang text alt facets], metadata["bluesky"].keys
      end

      def test_offers_the_first_picture_of_the_post_for_download
        thread = with_embed({"$type" => "app.bsky.embed.images#view", "images" => [{"thumb" => "https://cdn.example/1.jpg", "alt" => "Pic"}]})

        metadata = with_thread(thread) { Notes.bluesky_metadata(POST_URL) }

        assert_equal ["https://cdn.example/1.jpg"], metadata["image_urls"]
        assert_equal "Pic", metadata["bluesky"]["alt"]
      end

      def test_converts_facets_to_character_offsets
        record = THREAD["post"]["record"].merge(
          "text" => "Café ☕ example.com",
          "facets" => [{"index" => {"byteStart" => 10, "byteEnd" => 21}, "features" => [{"$type" => "app.bsky.richtext.facet#link", "uri" => "https://example.com/"}]}]
        )

        metadata = with_thread(with_embed(nil, "record" => record)) { Notes.bluesky_metadata(POST_URL) }

        assert_equal [{"from" => 7, "to" => 18, "url" => "https://example.com/"}], metadata["bluesky"]["facets"]
      end

      def test_leaves_out_what_the_post_does_not_have
        thread = with_embed(nil, "record" => {"createdAt" => "not a time"}, "author" => {"handle" => "ada.example.com", "displayName" => ""})

        metadata = with_thread(thread) { Notes.bluesky_metadata(POST_URL) }

        assert_equal({"handle" => "ada.example.com"}, metadata["bluesky"])
        assert_equal "", metadata["author"]
      end

      def test_reads_a_utf_8_body
        record = THREAD["post"]["record"].merge("text" => "Café ☕ — “Live”")
        thread = with_embed(nil, "record" => record, "author" => {"handle" => "zazolc.example.com", "displayName" => "Zażółć"})

        metadata = with_thread(thread) { Notes.bluesky_metadata(POST_URL) }

        assert_equal "Café ☕ — “Live”", metadata["bluesky"]["text"]
        assert_equal "Zażółć", metadata["author"]
        assert_equal Encoding::UTF_8, metadata["bluesky"]["text"].encoding
      end

      def test_a_post_that_is_gone_raises
        [
          {"$type" => "app.bsky.feed.defs#notFoundPost", "uri" => "at://x", "notFound" => true},
          {"$type" => "app.bsky.feed.defs#blockedPost", "uri" => "at://x", "blocked" => true}
        ].each do |thread|
          error = with_thread(thread) { assert_raises(RuntimeError) { Notes.bluesky_metadata(POST_URL) } }

          assert_equal "the post is not available (#{thread["$type"]})", error.message
        end
      end

      def test_a_failed_request_raises
        failing = ->(_url, **) { raise "400 Bad Request" }

        error = Notes.stub(:get, failing) { assert_raises(RuntimeError) { Notes.bluesky_metadata(POST_URL) } }

        assert_equal "400 Bad Request", error.message
      end

      def test_a_response_that_is_not_json_raises
        html = ->(url, **) { ["<html>hi</html>".b, url, "text/html"] }

        Notes.stub(:get, html) { assert_raises(JSON::ParserError) { Notes.bluesky_metadata(POST_URL) } }
      end

      def test_a_response_without_a_thread_raises
        empty = ->(url, **) { ["{}".b, url, "application/json"] }

        Notes.stub(:get, empty) { assert_raises(KeyError) { Notes.bluesky_metadata(POST_URL) } }
      end

      private

      # Returns THREAD with +embed+ on its post and +overrides+ replacing its post's keys.
      def with_embed(embed, **overrides)
        post = THREAD["post"].merge("embed" => embed, **overrides).compact
        THREAD.merge("post" => post)
      end

      # Runs the block with Notes.get answering with +thread+ as the API's
      # response, yielding the URLs requested so far.
      def with_thread(thread = THREAD)
        requested = []
        fake = lambda do |url, **|
          requested << url
          [JSON.generate({"thread" => thread}).b, url, "application/json"]
        end
        Notes.stub(:get, fake) { yield requested }
      end
    end
  end
end
