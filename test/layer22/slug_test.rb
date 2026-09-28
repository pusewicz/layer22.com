# frozen_string_literal: true

require "test_helper"

module Layer22
  class SlugTest < TestCase
    def test_slugify_lowercases_and_hyphenates_words
      assert_equal "hello-world", Slug.slugify("Hello World")
    end

    def test_slugify_turns_a_run_of_punctuation_into_one_hyphen
      assert_equal "a-b-c", Slug.slugify("a -- b, c!!")
    end

    def test_slugify_treats_underscores_as_separators
      assert_equal "snake-case-name", Slug.slugify("snake_case_name")
    end

    def test_slugify_trims_separators_from_both_ends
      assert_equal "hello", Slug.slugify("  --Hello!!  ")
    end

    def test_slugify_keeps_digits
      assert_equal "ruby-3-4-released", Slug.slugify("Ruby 3.4 released")
    end

    def test_slugify_keeps_unicode_letters_and_lowercases_them
      assert_equal "café-münster", Slug.slugify("Café Münster")
      assert_equal "école", Slug.slugify("ÉCOLE")
      assert_equal "日本語-テスト", Slug.slugify("日本語 テスト")
    end

    def test_slugify_keeps_combining_marks
      decomposed = "café au lait"

      assert_equal "café-au-lait", Slug.slugify(decomposed)
    end

    def test_slugify_drops_symbols_that_are_not_letters_or_digits
      assert_equal "c-c", Slug.slugify("C++ & C#")
    end

    def test_slugify_returns_an_empty_string_for_nil
      assert_equal "", Slug.slugify(nil)
    end

    def test_slugify_returns_an_empty_string_when_nothing_is_left
      assert_equal "", Slug.slugify("")
      assert_equal "", Slug.slugify(" -- !! ")
    end

    def test_slugify_converts_non_strings_with_to_s
      assert_equal "2021", Slug.slugify(2021)
      assert_equal "a-b", Slug.slugify(:"a b")
    end
  end
end
