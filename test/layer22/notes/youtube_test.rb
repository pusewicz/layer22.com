# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class YoutubeTest < TestCase
      ID = "dQw4w9WgXcQ"

      def test_youtube_hosts_are_youtube
        %w[
          https://www.youtube.com/watch?v=x
          https://youtube.com/watch?v=x
          https://m.youtube.com/watch?v=x
          https://music.youtube.com/watch?v=x
          https://youtu.be/x
        ].each { |url| assert Notes.youtube?(url), "#{url} should be YouTube" }
      end

      def test_other_hosts_are_not_youtube
        %w[
          https://vimeo.com/watch?v=x
          https://notyoutube.com/watch?v=x
          https://youtube.com.example.com/watch?v=x
          https://example.com/youtube.com/watch?v=x
          https://www.youtube-nocookie.com/embed/x
        ].each { |url| refute Notes.youtube?(url), "#{url} should not be YouTube" }
      end

      def test_the_host_is_matched_in_any_case
        %w[
          https://WWW.YOUTUBE.COM/watch?v=x
          https://Music.YouTube.com/watch?v=x
          HTTPS://YOUTUBE.COM/watch?v=x
          https://YOUTU.BE/x
        ].each { |url| assert Notes.youtube?(url), "#{url} should be YouTube" }
        refute Notes.youtube?("https://NOTYOUTUBE.COM/watch?v=x")
      end

      def test_a_youtube_url_without_a_video_is_still_youtube
        assert Notes.youtube?("https://www.youtube.com/@channel")
      end

      def test_a_url_without_a_host_is_not_youtube
        refute Notes.youtube?("mailto:someone@example.com")
      end

      def test_reads_the_id_from_a_watch_url
        assert_equal ID, Notes.youtube_id("https://www.youtube.com/watch?v=#{ID}")
      end

      def test_reads_the_id_from_a_watch_url_with_other_parameters
        assert_equal ID, Notes.youtube_id("https://www.youtube.com/watch?feature=share&v=#{ID}&t=5s")
        assert_equal ID, Notes.youtube_id("https://www.youtube.com/watch?v=#{ID}&list=PL123")
      end

      def test_reads_the_first_v_parameter
        assert_equal ID, Notes.youtube_id("https://www.youtube.com/watch?v=#{ID}&v=other123456")
      end

      def test_reads_the_id_from_a_youtu_be_url
        assert_equal ID, Notes.youtube_id("https://youtu.be/#{ID}")
        assert_equal ID, Notes.youtube_id("https://youtu.be/#{ID}?t=10")
        assert_equal ID, Notes.youtube_id("https://youtu.be/#{ID}?si=abc&t=10")
      end

      def test_reads_the_id_from_shorts_live_embed_and_v_urls
        %w[shorts live embed v].each do |kind|
          assert_equal ID, Notes.youtube_id("https://www.youtube.com/#{kind}/#{ID}"), kind
          assert_equal ID, Notes.youtube_id("https://www.youtube.com/#{kind}/#{ID}?feature=share"), kind
        end
      end

      def test_reads_the_id_when_a_path_follows_it
        assert_equal ID, Notes.youtube_id("https://www.youtube.com/shorts/#{ID}/extra")
      end

      def test_reads_the_id_on_every_youtube_host
        %w[youtube.com www.youtube.com m.youtube.com music.youtube.com].each do |host|
          assert_equal ID, Notes.youtube_id("https://#{host}/watch?v=#{ID}"), host
        end
      end

      def test_reads_the_id_when_the_host_is_in_upper_case
        assert_equal ID, Notes.youtube_id("https://WWW.YOUTUBE.COM/watch?v=#{ID}")
        assert_equal ID, Notes.youtube_id("https://Music.YouTube.com/watch?v=#{ID}")
        assert_equal ID, Notes.youtube_id("HTTPS://WWW.YOUTUBE.COM/shorts/#{ID}")
        assert_equal ID, Notes.youtube_id("https://YOUTU.BE/#{ID}")
        assert_equal ID, Notes.youtube_id("https://YouTu.Be/#{ID}?t=10")
        assert_nil Notes.youtube_id("https://NOTYOUTUBE.COM/watch?v=#{ID}")
      end

      def test_ids_may_contain_dashes_and_underscores
        assert_equal "a-_B1234567", Notes.youtube_id("https://youtu.be/a-_B1234567")
      end

      def test_an_id_of_the_wrong_length_is_not_an_id
        assert_nil Notes.youtube_id("https://www.youtube.com/watch?v=short")
        assert_nil Notes.youtube_id("https://www.youtube.com/watch?v=#{ID}x")
        assert_nil Notes.youtube_id("https://youtu.be/#{ID}x")
        assert_nil Notes.youtube_id("https://www.youtube.com/shorts/#{ID}x")
      end

      def test_an_id_with_invalid_characters_is_not_an_id
        assert_nil Notes.youtube_id("https://www.youtube.com/watch?v=a-_B123456!")
        assert_nil Notes.youtube_id("https://www.youtube.com/watch?v=a-_B123 4567")
      end

      def test_a_url_without_an_id_has_none
        assert_nil Notes.youtube_id("https://www.youtube.com/")
        assert_nil Notes.youtube_id("https://www.youtube.com/watch")
        assert_nil Notes.youtube_id("https://www.youtube.com/watch?v=")
        assert_nil Notes.youtube_id("https://youtu.be/")
        assert_nil Notes.youtube_id("https://www.youtube.com/embed/")
        assert_nil Notes.youtube_id("https://www.youtube.com/channel/UC1234567890")
      end

      def test_a_video_id_on_another_host_is_ignored
        assert_nil Notes.youtube_id("https://vimeo.com/watch?v=#{ID}")
        assert_nil Notes.youtube_id("https://notyoutube.com/watch?v=#{ID}")
        assert_nil Notes.youtube_id("https://youtube.com.example.com/watch?v=#{ID}")
        assert_nil Notes.youtube_id("mailto:someone@example.com")
      end
    end

    class TruncateTest < TestCase
      def test_returns_short_text_unchanged
        assert_equal "short", Notes.truncate("short", 10)
        assert_equal "", Notes.truncate("", 5)
      end

      def test_returns_text_of_exactly_the_length_unchanged
        assert_equal "hello worl", Notes.truncate("hello worl", 10)
      end

      def test_shortens_text_one_over_the_length
        assert_equal "aaaaaaaaa…", Notes.truncate("a" * 11, 10)
      end

      def test_breaks_between_words
        assert_equal "hello wonderful…", Notes.truncate("hello wonderful world", 20)
      end

      def test_never_leaves_a_partial_word
        assert_equal "hello…", Notes.truncate("hello wonderful world", 12)
        assert_equal "hello…", Notes.truncate("hello wonderful world", 13)
      end

      def test_drops_the_whitespace_before_the_ellipsis
        assert_equal "one two…", Notes.truncate("one two  three", 9)
      end

      def test_breaks_a_single_long_word
        assert_equal "supercali…", Notes.truncate("supercalifragilistic", 10)
      end

      def test_result_is_never_longer_than_the_length
        text = "The quick brown fox jumps over the lazy dog and keeps running"

        (2..text.length).each do |length|
          assert_operator Notes.truncate(text, length).length, :<=, length, "length #{length}"
        end
      end

      def test_counts_characters_not_bytes
        assert_equal "żółć żółć…", Notes.truncate("żółć żółć żółć", 11)
        assert_equal "żółć żółć żółć", Notes.truncate("żółć żółć żółć", 14)
      end
    end
  end
end
