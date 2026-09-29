# frozen_string_literal: true

require "test_helper"

module Layer22
  module Content
    class BlueskyPostTest < TestCase
      DATA = {
        "handle" => "ada.example.com",
        "date" => "2021-05-06T22:30:00Z",
        "lang" => "en",
        "text" => "Hello example.com",
        "alt" => "A pic",
        "facets" => [{"from" => 6, "to" => 17, "url" => "https://example.com/"}]
      }.freeze

      def test_from_front_matter_returns_nil_without_a_post
        assert_nil BlueskyPost.from_front_matter(nil)
      end

      def test_from_front_matter_copies_the_saved_post
        post = BlueskyPost.from_front_matter(DATA)

        assert_equal "ada.example.com", post.handle
        assert_equal "Hello example.com", post.text
        assert_equal "en", post.lang
        assert_equal "A pic", post.alt
        assert_equal [BlueskyPost::Facet.new(from: 6, to: 17, url: "https://example.com/")], post.facets
      end

      def test_from_front_matter_reads_the_date_in_the_local_zone
        date = BlueskyPost.from_front_matter(DATA).date

        assert_equal Time.utc(2021, 5, 6, 22, 30), date
        assert_equal "2021-05-07T00:30:00+02:00", date.xmlschema
      end

      def test_from_front_matter_reads_a_date_written_as_a_yaml_timestamp
        date = BlueskyPost.from_front_matter(DATA.merge("date" => Time.utc(2021, 5, 6, 22, 30))).date

        assert_equal "2021-05-07T00:30:00+02:00", date.xmlschema
      end

      def test_from_front_matter_leaves_absent_details_empty
        post = BlueskyPost.from_front_matter({"handle" => "ada.example.com"})

        assert_equal "", post.text
        assert_nil post.date
        assert_nil post.lang
        assert_nil post.alt
        assert_equal [], post.facets
      end

      def test_from_front_matter_requires_a_handle
        error = assert_raises(KeyError) { BlueskyPost.from_front_matter(DATA.except("handle")) }

        assert_includes error.message, "handle"
      end

      def test_from_front_matter_requires_each_facet_to_have_its_range_and_url
        %w[from to url].each do |key|
          facet = DATA["facets"].first.except(key)

          error = assert_raises(KeyError) { BlueskyPost.from_front_matter(DATA.merge("facets" => [facet])) }

          assert_includes error.message, key
        end
      end

      def test_from_front_matter_names_an_invalid_date
        error = assert_raises(ArgumentError) { BlueskyPost.from_front_matter(DATA.merge("date" => "yesterday")) }

        assert_equal 'link.bluesky.date: invalid date "yesterday"', error.message
      end

      def test_segments_of_plain_text_is_the_text
        assert_equal [["Hello", nil]], post("Hello").segments
      end

      def test_segments_of_no_text_is_empty
        assert_equal [], post("").segments
      end

      def test_segments_split_around_a_link
        assert_equal [["Visit ", nil], ["example.com", "https://a.test/"], [" now", nil]],
          post("Visit example.com now", facet(6, 17)).segments
      end

      def test_segments_start_and_end_with_links
        assert_equal [["Hi", "https://a.test/"], [" and ", nil], ["bye", "https://a.test/"]],
          post("Hi and bye", facet(0, 2), facet(7, 10)).segments
      end

      def test_segments_keep_adjacent_links_apart
        assert_equal [["ab", "https://a.test/"], ["cd", "https://a.test/"]], post("abcd", facet(0, 2), facet(2, 4)).segments
      end

      def test_segments_are_ordered_by_position
        assert_equal [["a", "https://a.test/"], [" ", nil], ["b", "https://a.test/"]], post("a b", facet(2, 3), facet(0, 1)).segments
      end

      def test_segments_count_characters_not_bytes
        assert_equal [["Café ☕ ", nil], ["example.com", "https://a.test/"]], post("Café ☕ example.com", facet(7, 18)).segments
      end

      def test_segments_skip_a_facet_that_overlaps_an_earlier_one
        assert_equal [["abc", "https://a.test/"], ["d", nil]], post("abcd", facet(0, 3), facet(2, 4)).segments
      end

      def test_segments_skip_facets_that_are_empty_reversed_or_beyond_the_text
        assert_equal [["abc", nil]], post("abc", facet(1, 1), facet(2, 1), facet(1, 9), facet(-1, 2)).segments
      end

      def test_segments_reassemble_the_text
        text = "Café ☕ notes at example.com #lisp\nSecond line"
        segments = post(text, facet(16, 27), facet(28, 33)).segments

        assert_equal text, segments.map(&:first).join
      end

      private

      def facet(from, to)
        BlueskyPost::Facet.new(from:, to:, url: "https://a.test/")
      end

      def post(text, *facets)
        BlueskyPost.new(handle: "ada.example.com", text:, date: nil, lang: nil, alt: nil, facets:)
      end
    end
  end
end
