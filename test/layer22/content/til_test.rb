# frozen_string_literal: true

require "test_helper"
require_relative "../local_time_assertions"

module Layer22
  module Content
    class TILTest < TestCase
      include LocalTimeAssertions

      def self.fixture_tils
        @fixture_tils ||= Dir.chdir(FIXTURE_ROOT) { TIL.load_all("_til", words_per_minute: 100.0) }.to_h { |til| [til.slug, til] }
      end

      def test_load_all_reads_the_fixture_tils_in_path_order
        assert_equal %w[first-til second-til third-til], fixture_tils.keys
      end

      def test_first_til_takes_its_date_from_the_filename
        til = fixture_tils.fetch("first-til")

        assert_local_time "2021-03-05 00:00:00 +0100", til.date
        assert_equal "/til/2021/03/05/first-til/", til.permalink
        assert_equal "_til/2021/03/2021-03-05-first-til.md", til.relative_path
      end

      def test_first_til_reads_its_metadata
        til = fixture_tils.fetch("first-til")

        assert_equal "First TIL", til.title
        assert_equal %w[ruby], til.tags
        assert_equal [], til.categories
        assert_equal "Learned something small.", til.description
        assert_equal "<p>Learned something small.</p>\n", til.body_html
        assert_local_time "2021-03-05 08:00:00 +0100", til.last_modified_at
      end

      def test_first_til_counts_words_and_reading_time
        til = fixture_tils.fetch("first-til")

        assert_equal 3, til.word_count
        assert_equal 1, til.reading_time
      end

      def test_second_til_prefers_the_front_matter_date
        til = fixture_tils.fetch("second-til")

        assert_local_time "2021-03-20 18:45:00 +0100", til.date
        assert_equal "/til/2021/03/20/second-til/", til.permalink
        assert_equal %w[git], til.tags
      end

      def test_third_til_highlights_code_and_describes_itself_with_it
        til = fixture_tils.fetch("third-til")

        assert_includes til.body_html, '<div class="language-sh highlighter-rouge">'
        assert_equal "git status", til.description
        assert_equal 2, til.word_count
        assert_equal "/til/2022/01/10/third-til/", til.permalink
      end

      def test_permalink_uses_the_local_date_of_a_utc_timestamp
        til = load_til("2021-03-05-late.md", "---\ndate: 2021-03-05 23:30:00 +0000\n---\nBody.")

        assert_local_time "2021-03-06 00:30:00 +0100", til.date
        assert_equal "/til/2021/03/06/late/", til.permalink
      end

      def test_permalink_pads_month_and_day
        assert_equal "/til/2021/01/02/x/", load_til("2021-01-02-x.md", "Body.").permalink
      end

      def test_slug_drops_only_the_leading_date_from_the_filename
        assert_equal "2021-recap", load_til("2021-02-03-2021-recap.md", "Body.").slug
      end

      def test_title_falls_back_to_the_slug
        assert_equal "untitled", load_til("2021-02-03-untitled.md", "Body.").title
      end

      def test_title_decodes_entities
        assert_equal "Fish & chips", load_til("2021-02-03-x.md", "---\ntitle: Fish &amp; chips\n---\nBody.").title
      end

      def test_description_prefers_front_matter
        til = load_til("2021-02-03-x.md", "---\ndescription: Custom.\n---\nFirst paragraph.")

        assert_equal "Custom.", til.description
      end

      def test_reads_singular_and_plural_taxonomy_keys
        singular = load_til("2021-02-03-x.md", "---\ntag: one\ncategory: two\n---\nBody.")
        plural = load_til("2021-02-03-x.md", "---\ntags: a b\ncategories: [c, d]\n---\nBody.")

        assert_equal [%w[one], %w[two]], [singular.tags, singular.categories]
        assert_equal [%w[a b], %w[c d]], [plural.tags, plural.categories]
      end

      def test_last_modified_at_falls_back_to_the_file_time
        with_site({"_til/2021-02-03-x.md" => "Body."}) do
          File.utime(Time.utc(2001, 2, 3, 4, 5, 6), Time.utc(2001, 2, 3, 4, 5, 6), "_til/2021-02-03-x.md")

          assert_equal Time.utc(2001, 2, 3, 4, 5, 6), TIL.load_all("_til").first.last_modified_at
        end
      end

      def test_reading_time_uses_the_given_words_per_minute
        body = ("word " * 250).strip

        assert_equal 3, load_til("2021-02-03-x.md", body, words_per_minute: 100.0).reading_time
        assert_equal 2, load_til("2021-02-03-x.md", body, words_per_minute: 180.0).reading_time
        assert_equal 2, load_til("2021-02-03-x.md", body).reading_time
      end

      def test_an_undated_til_falls_back_to_the_current_time
        til = load_til("undated.md", "Body.")

        assert_in_delta Time.now.to_f, til.date.to_f, 5
        assert_equal "/til/#{til.date.strftime("%Y/%m/%d")}/undated/", til.permalink
      end

      def test_load_all_finds_tils_in_nested_directories_and_both_extensions
        files = {
          "_til/2021/03/2021-03-01-a.md" => "A",
          "_til/2021/03/2021-03-02-b.markdown" => "B",
          "_til/2021-03-03-c.md" => "C",
          "_til/2021-03-04-ignored.txt" => "D"
        }

        with_site(files) do
          assert_equal %w[a b c], TIL.load_all("_til").map(&:slug).sort
        end
      end

      def test_an_invalid_date_raises_naming_the_file
        error = assert_raises(ArgumentError) { load_til("2021-02-03-x.md", "---\ndate: someday\n---\nBody.") }

        assert_equal '_til/2021-02-03-x.md: invalid date "someday"', error.message
      end

      def test_an_impossible_filename_date_raises_naming_the_file
        error = assert_raises(ArgumentError) { load_til("2021-13-45-x.md", "Body.") }

        assert_equal '_til/2021-13-45-x.md: invalid date "2021-13-45"', error.message
      end

      private

      def fixture_tils
        self.class.fixture_tils
      end

      def load_til(filename, content, **options)
        with_site({"_til/#{filename}" => content}) do
          tils = TIL.load_all("_til", **options)
          assert_equal 1, tils.size
          tils.first
        end
      end
    end
  end
end
