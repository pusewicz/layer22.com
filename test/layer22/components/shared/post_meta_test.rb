# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class PostMetaTest < TestCase
        def hello_world
          fixture_site.posts.first
        end

        def meta(post = hello_world)
          parse_html(PostMeta.new(site: fixture_site, post:).call)
        end

        def test_shows_the_date_with_its_year
          time = meta.at_css("time")

          assert_equal "Mar 14 2019", time.text
          assert_equal "2019-03-14T00:00:00+01:00", time["datetime"]
        end

        def test_labels_the_date_in_full_for_screen_readers
          assert_equal "posted on Thursday, 14 of March, 2019", meta.at_css("time")["aria-label"]
        end

        def test_leaves_out_the_year_for_dates_in_the_current_year
          date = Time.local(Time.now.year, 3, 5, 12)
          time = meta(hello_world.with(date:)).at_css("time")

          assert_equal "Mar 5", time.text
          assert_equal date.xmlschema, time["datetime"]
        end

        def test_shows_the_reading_time_and_word_count
          reading = meta.at_css(".word-count")

          assert_equal "1 min read", reading.text
          assert_equal "35 words", reading["title"]
        end

        def test_labels_the_reading_time_for_screen_readers
          reading = meta(hello_world.with(word_count: 420, reading_time: 3)).at_css(".word-count")

          assert_equal "3 min read", reading.text
          assert_equal "420 words", reading["title"]
          assert_equal "3 minutes to read this post", reading["aria-label"]
        end

        def test_hides_the_separator_from_screen_readers
          separator = meta.at_css("span[aria-hidden=true]")

          assert_equal "·", separator.text.strip
        end
      end
    end
  end
end
