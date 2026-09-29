# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class BlueskyPostUrlTest < TestCase
      POST = "https://bsky.app/profile/dean-dev.bsky.social/post/3mvicwpmoak2q"

      def test_splits_a_post_url_into_the_handle_and_record_key
        assert_equal ["dean-dev.bsky.social", "3mvicwpmoak2q"], Notes.bluesky_post(POST)
      end

      def test_accepts_a_did_in_place_of_a_handle
        assert_equal ["did:plc:aj6haplxvsp57ac6cpejgv27", "3mvicwpmoak2q"],
          Notes.bluesky_post("https://bsky.app/profile/did:plc:aj6haplxvsp57ac6cpejgv27/post/3mvicwpmoak2q")
      end

      def test_ignores_a_trailing_slash_query_and_fragment
        assert_equal ["dean-dev.bsky.social", "3mvicwpmoak2q"], Notes.bluesky_post("#{POST}/?ref=share#top")
      end

      def test_the_host_is_matched_in_any_case
        assert_equal ["dean-dev.bsky.social", "3mvicwpmoak2q"], Notes.bluesky_post(POST.sub("bsky.app", "BSKY.app"))
      end

      def test_other_bsky_app_pages_are_not_posts
        %w[
          https://bsky.app/
          https://bsky.app/profile/dean-dev.bsky.social
          https://bsky.app/profile/dean-dev.bsky.social/feed/whats-hot
          https://bsky.app/profile/dean-dev.bsky.social/post/
          https://bsky.app/profile/dean-dev.bsky.social/post/3mvicwpmoak2q/liked-by
          https://bsky.app/hashtag/gamedev
        ].each { |url| assert_nil Notes.bluesky_post(url), "#{url} should not be a post" }
      end

      def test_other_hosts_are_not_bluesky
        %w[
          https://bsky.social/profile/dean-dev.bsky.social/post/3mvicwpmoak2q
          https://notbsky.app/profile/dean-dev.bsky.social/post/3mvicwpmoak2q
          https://bsky.app.example.com/profile/dean-dev.bsky.social/post/3mvicwpmoak2q
          https://example.com/bsky.app/profile/dean-dev.bsky.social/post/3mvicwpmoak2q
        ].each { |url| assert_nil Notes.bluesky_post(url), "#{url} should not be a post" }
      end
    end

    class BlueskyMediaTest < TestCase
      def test_takes_the_first_image_and_its_alt_text
        embed = {
          "$type" => "app.bsky.embed.images#view",
          "images" => [
            {"thumb" => "https://cdn.example/1.jpg", "fullsize" => "https://cdn.example/1-full.jpg", "alt" => "First"},
            {"thumb" => "https://cdn.example/2.jpg", "alt" => "Second"}
          ]
        }

        assert_equal({image: "https://cdn.example/1.jpg", alt: "First"}, Notes.bluesky_media(embed))
      end

      def test_takes_the_first_image_of_a_gallery
        embed = {
          "$type" => "app.bsky.embed.gallery#view",
          "items" => [
            {"thumbnail" => "https://cdn.example/1.jpg", "alt" => "First"},
            {"thumbnail" => "https://cdn.example/2.jpg", "alt" => "Second"}
          ]
        }

        assert_equal({image: "https://cdn.example/1.jpg", alt: "First"}, Notes.bluesky_media(embed))
      end

      def test_takes_the_thumbnail_of_a_video
        embed = {"$type" => "app.bsky.embed.video#view", "thumbnail" => "https://video.example/t.jpg", "playlist" => "https://video.example/p.m3u8"}

        assert_equal({image: "https://video.example/t.jpg", alt: nil}, Notes.bluesky_media(embed))
      end

      def test_takes_the_alt_text_of_a_video
        embed = {"$type" => "app.bsky.embed.video#view", "thumbnail" => "https://video.example/t.jpg", "alt" => "A trailer"}

        assert_equal "A trailer", Notes.bluesky_media(embed)[:alt]
      end

      def test_takes_the_preview_image_of_a_link
        embed = {"$type" => "app.bsky.embed.external#view", "external" => {"uri" => "https://example.com/", "thumb" => "https://cdn.example/preview.jpg"}}

        assert_equal({image: "https://cdn.example/preview.jpg"}, Notes.bluesky_media(embed))
      end

      def test_takes_the_media_next_to_a_quoted_post
        embed = {
          "$type" => "app.bsky.embed.recordWithMedia#view",
          "record" => {"$type" => "app.bsky.embed.record#view"},
          "media" => {"$type" => "app.bsky.embed.images#view", "images" => [{"thumb" => "https://cdn.example/1.jpg", "alt" => "Pic"}]}
        }

        assert_equal({image: "https://cdn.example/1.jpg", alt: "Pic"}, Notes.bluesky_media(embed))
      end

      def test_a_quoted_post_has_no_media
        assert_equal({}, Notes.bluesky_media({"$type" => "app.bsky.embed.record#view", "record" => {}}))
      end

      def test_a_post_without_an_embed_has_no_media
        assert_equal({}, Notes.bluesky_media(nil))
      end

      def test_an_unknown_embed_has_no_media
        assert_equal({}, Notes.bluesky_media({"$type" => "app.bsky.embed.hologram#view"}))
      end

      def test_an_embed_without_pictures_has_none
        assert_equal({image: nil, alt: nil}, Notes.bluesky_media({"$type" => "app.bsky.embed.images#view", "images" => []}))
        assert_equal({image: nil, alt: nil}, Notes.bluesky_media({"$type" => "app.bsky.embed.gallery#view"}))
      end
    end

    class BlueskyDateTest < TestCase
      def test_normalizes_to_utc
        assert_equal "2021-05-06T22:30:00Z", Notes.bluesky_date("2021-05-06T22:30:00.123Z")
        assert_equal "2021-05-06T20:30:00Z", Notes.bluesky_date("2021-05-06T22:30:00+02:00")
      end

      def test_a_missing_or_invalid_date_is_nil
        assert_nil Notes.bluesky_date(nil)
        assert_nil Notes.bluesky_date("")
        assert_nil Notes.bluesky_date("yesterday")
      end
    end

    class BlueskyFacetsTest < TestCase
      LINK = "app.bsky.richtext.facet#link"
      MENTION = "app.bsky.richtext.facet#mention"
      TAG = "app.bsky.richtext.facet#tag"

      def test_a_link_points_at_its_uri
        facets = Notes.bluesky_facets("Visit example.com now", [facet(6, 17, LINK, "uri" => "https://example.com/full")])

        assert_equal [{"from" => 6, "to" => 17, "url" => "https://example.com/full"}], facets
      end

      def test_a_mention_points_at_the_profile_of_its_did
        facets = Notes.bluesky_facets("Hi @ada.example.com", [facet(3, 19, MENTION, "did" => "did:plc:abc123")])

        assert_equal [{"from" => 3, "to" => 19, "url" => "https://bsky.app/profile/did:plc:abc123"}], facets
      end

      def test_a_hashtag_points_at_its_tag_page
        facets = Notes.bluesky_facets("Go #gamedev", [facet(3, 11, TAG, "tag" => "gamedev")])

        assert_equal [{"from" => 3, "to" => 11, "url" => "https://bsky.app/hashtag/gamedev"}], facets
      end

      def test_a_hashtag_is_escaped_in_the_url
        facets = Notes.bluesky_facets("Go #café", [facet(3, 9, TAG, "tag" => "café")])

        assert_equal "https://bsky.app/hashtag/caf%C3%A9", facets.first["url"]
      end

      def test_byte_offsets_become_character_offsets
        text = "Café ☕ example.com"
        facets = Notes.bluesky_facets(text, [facet(10, 21, LINK, "uri" => "https://example.com/")])

        assert_equal [{"from" => 7, "to" => 18, "url" => "https://example.com/"}], facets
        assert_equal "example.com", text[7...18]
      end

      def test_offsets_after_a_four_byte_character
        text = "🎉 #lisp"
        facets = Notes.bluesky_facets(text, [facet(5, 10, TAG, "tag" => "lisp")])

        assert_equal [{"from" => 2, "to" => 7, "url" => "https://bsky.app/hashtag/lisp"}], facets
        assert_equal "#lisp", text[2...7]
      end

      def test_keeps_the_order_of_the_post
        facets = Notes.bluesky_facets("a b", [facet(0, 1, TAG, "tag" => "a"), facet(2, 3, TAG, "tag" => "b")])

        assert_equal [0, 2], facets.map { |facet| facet["from"] }
      end

      def test_uses_the_first_feature_that_is_understood
        multi = {
          "index" => {"byteStart" => 0, "byteEnd" => 3},
          "features" => [{"$type" => "app.bsky.richtext.facet#hologram"}, {"$type" => LINK, "uri" => "https://example.com/"}]
        }

        assert_equal "https://example.com/", Notes.bluesky_facets("abc", [multi]).first["url"]
      end

      def test_no_facets_is_an_empty_list
        assert_equal [], Notes.bluesky_facets("text", nil)
        assert_equal [], Notes.bluesky_facets("text", [])
      end

      def test_drops_links_that_are_not_http
        facets = %w[javascript:alert(1) mailto:a@example.com data:text/html,hi ftp://example.com/].map do |uri|
          facet(0, 4, LINK, "uri" => uri)
        end

        assert_equal [], Notes.bluesky_facets("text", facets)
      end

      def test_keeps_http_and_https_links_in_any_case
        facets = ["http://example.com/", "HTTPS://example.com/"].map { |uri| facet(0, 4, LINK, "uri" => uri) }

        assert_equal 2, Notes.bluesky_facets("text", facets).size
      end

      def test_drops_a_link_without_a_uri
        assert_equal [], Notes.bluesky_facets("text", [facet(0, 4, LINK)])
      end

      def test_drops_a_facet_no_feature_of_which_is_understood
        assert_equal [], Notes.bluesky_facets("text", [facet(0, 4, "app.bsky.richtext.facet#hologram")])
        assert_equal [], Notes.bluesky_facets("text", [{"index" => {"byteStart" => 0, "byteEnd" => 4}}])
      end

      def test_drops_facets_whose_offsets_are_unusable
        link = {"$type" => LINK, "uri" => "https://example.com/"}
        [
          nil,
          {},
          {"byteStart" => 0},
          {"byteEnd" => 4},
          {"byteStart" => "0", "byteEnd" => "4"},
          {"byteStart" => -1, "byteEnd" => 4},
          {"byteStart" => 2, "byteEnd" => 2},
          {"byteStart" => 3, "byteEnd" => 2},
          {"byteStart" => 0, "byteEnd" => 5}
        ].each do |index|
          assert_equal [], Notes.bluesky_facets("text", [{"index" => index, "features" => [link]}]), index.inspect
        end
      end

      def test_drops_facets_that_split_a_character
        link = [{"$type" => LINK, "uri" => "https://example.com/"}]

        assert_equal [], Notes.bluesky_facets("é!", [{"index" => {"byteStart" => 0, "byteEnd" => 1}, "features" => link}])
        assert_equal [], Notes.bluesky_facets("é!", [{"index" => {"byteStart" => 1, "byteEnd" => 3}, "features" => link}])
        assert_equal 1, Notes.bluesky_facets("é!", [{"index" => {"byteStart" => 0, "byteEnd" => 2}, "features" => link}]).size
      end

      private

      def facet(first, last, type, **feature)
        {"index" => {"byteStart" => first, "byteEnd" => last}, "features" => [{"$type" => type, **feature}]}
      end
    end
  end
end
