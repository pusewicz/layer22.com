# frozen_string_literal: true

require "test_helper"
require_relative "../local_time_assertions"

module Layer22
  module Content
    class TimestampTest < TestCase
      include LocalTimeAssertions

      def test_parse_reads_a_string_with_an_offset_into_the_local_zone
        assert_local_time "2021-01-01 00:30:00 +0100", Timestamp.parse("2020-12-31 23:30:00 +0000", source: "post.md")
      end

      def test_parse_uses_the_daylight_saving_offset_of_the_date
        assert_local_time "2021-06-01 14:00:00 +0200", Timestamp.parse("2021-06-01 12:00:00 +0000", source: "post.md")
        assert_local_time "2021-01-15 13:00:00 +0100", Timestamp.parse("2021-01-15 12:00:00 +0000", source: "post.md")
      end

      def test_parse_reads_a_string_without_an_offset_as_local_time
        assert_local_time "2021-05-01 09:30:00 +0200", Timestamp.parse("2021-05-01 09:30:00", source: "note.md")
      end

      def test_parse_reads_a_date_only_string_as_local_midnight
        assert_local_time "2019-03-14 00:00:00 +0100", Timestamp.parse("2019-03-14", source: "post.md")
      end

      def test_parse_reads_a_date
        assert_local_time "2021-05-01 00:00:00 +0200", Timestamp.parse(Date.new(2021, 5, 1), source: "post.md")
      end

      def test_parse_reads_a_utc_time
        assert_local_time "2021-01-01 00:30:00 +0100", Timestamp.parse(Time.utc(2020, 12, 31, 23, 30), source: "post.md")
      end

      def test_parse_reads_a_time_with_an_offset
        time = Time.new(2021, 3, 20, 18, 45, 0, "+01:00")

        assert_local_time "2021-03-20 18:45:00 +0100", Timestamp.parse(time, source: "til.md")
      end

      def test_parse_follows_the_process_timezone
        with_zone("America/New_York") do
          assert_local_time "2020-12-31 18:30:00 -0500", Timestamp.parse("2020-12-31 23:30:00 +0000", source: "post.md")
        end
      end

      def test_parse_returns_nil_for_blank_values
        assert_nil Timestamp.parse(nil, source: "post.md")
        assert_nil Timestamp.parse("", source: "post.md")
        assert_nil Timestamp.parse("  \n", source: "post.md")
      end

      def test_parse_raises_naming_the_source_for_an_invalid_string
        error = assert_raises(ArgumentError) { Timestamp.parse("not a date", source: "_posts/broken.md") }

        assert_equal '_posts/broken.md: invalid date "not a date"', error.message
      end

      def test_parse_raises_naming_the_source_for_an_impossible_date
        error = assert_raises(ArgumentError) { Timestamp.parse("2021-13-45", source: "_posts/2021-13-45-x.md") }

        assert_equal '_posts/2021-13-45-x.md: invalid date "2021-13-45"', error.message
      end

      private

      def with_zone(zone)
        original = ENV["TZ"]
        ENV["TZ"] = zone
        yield
      ensure
        ENV["TZ"] = original
      end
    end
  end
end
