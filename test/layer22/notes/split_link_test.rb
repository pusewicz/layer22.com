# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class SplitLinkTest < TestCase
      WIKIPEDIA = "https://en.wikipedia.org/wiki/Ruby_(programming_language)"

      def test_takes_a_url_at_the_start
        assert_equal ["My comment", "https://example.com/post"], Notes.split_link("https://example.com/post My comment")
      end

      def test_takes_a_url_at_the_end
        assert_equal ["My comment", "https://example.com/post"], Notes.split_link("My comment https://example.com/post")
      end

      def test_takes_a_url_on_its_own_line_at_the_start
        assert_equal ["Text", "https://example.com/"], Notes.split_link("https://example.com/\n\nText")
      end

      def test_takes_a_url_on_its_own_line_at_the_end
        text = "First\n\nSecond\n\nhttps://example.com/?a=1&b=2#top"

        assert_equal ["First\n\nSecond", "https://example.com/?a=1&b=2#top"], Notes.split_link(text)
      end

      def test_a_url_and_nothing_else_leaves_an_empty_body
        assert_equal ["", "https://example.com/"], Notes.split_link("https://example.com/")
      end

      def test_strips_whitespace_around_the_text
        assert_equal ["", "https://example.com"], Notes.split_link("  \n https://example.com \t\n")
        assert_equal ["Hi", "https://example.com"], Notes.split_link("\n  Hi   https://example.com\n\n")
      end

      def test_a_url_in_the_middle_stays_in_the_body
        text = "See https://example.com/a for details"

        assert_equal [text, nil], Notes.split_link(text)
      end

      def test_a_url_in_the_middle_of_a_later_line_stays_in_the_body
        text = "Intro\nhttps://example.com/a and more"

        assert_equal [text, nil], Notes.split_link(text)
      end

      def test_text_without_a_url_is_returned_stripped
        assert_equal ["Just words.", nil], Notes.split_link("  Just words.\n")
      end

      def test_empty_and_blank_text_have_neither_body_nor_url
        assert_equal ["", nil], Notes.split_link("")
        assert_equal ["", nil], Notes.split_link(" \n\t ")
      end

      def test_the_leading_url_wins_over_a_trailing_one
        assert_equal ["and https://b.example", "https://a.example"], Notes.split_link("https://a.example and https://b.example")
        assert_equal ["https://b.example", "https://a.example"], Notes.split_link("https://a.example https://b.example")
      end

      def test_takes_only_the_last_url_when_the_start_has_none
        assert_equal ["Compare https://a.example with", "https://b.example"], Notes.split_link("Compare https://a.example with https://b.example")
      end

      def test_keeps_sentence_punctuation_out_of_a_trailing_url
        assert_equal ["Read this:", "https://example.com/post"], Notes.split_link("Read this: https://example.com/post.")
        assert_equal ["Wow", "https://example.com/post"], Notes.split_link("Wow https://example.com/post!?")
      end

      def test_keeps_sentence_punctuation_out_of_a_leading_url
        assert_equal ["and text", "https://example.com"], Notes.split_link("https://example.com, and text")
      end

      def test_a_url_followed_only_by_punctuation_has_no_body
        assert_equal ["", "https://example.com"], Notes.split_link("https://example.com.")
      end

      def test_keeps_a_balanced_parenthesis_in_the_url
        assert_equal ["Read", WIKIPEDIA], Notes.split_link("Read #{WIKIPEDIA}")
        assert_equal ["Read", WIKIPEDIA], Notes.split_link("Read #{WIKIPEDIA}.")
        assert_equal ["Read", WIKIPEDIA], Notes.split_link("#{WIKIPEDIA} Read")
      end

      def test_accepts_http_as_well_as_https
        assert_equal ["Old site", "http://example.com/"], Notes.split_link("Old site http://example.com/")
      end

      def test_a_markdown_link_at_the_end_is_not_a_trailing_url
        text = "See [the post](https://example.com/post)"

        assert_equal [text, nil], Notes.split_link(text)
      end

      def test_a_url_glued_to_a_word_is_not_a_trailing_url
        assert_equal ["foohttps://example.com", nil], Notes.split_link("foohttps://example.com")
      end

      def test_a_leading_url_needs_whitespace_after_it
        text = "https://example.com<b>bold</b> text"

        assert_equal [text, nil], Notes.split_link(text)
      end

      def test_other_schemes_are_not_urls
        assert_equal ["ftp://example.com/file", nil], Notes.split_link("ftp://example.com/file")
      end
    end

    class TrimUrlTest < TestCase
      WIKIPEDIA = "https://en.wikipedia.org/wiki/Ruby_(programming_language)"

      {"." => "full stop", "," => "comma", ";" => "semicolon", ":" => "colon", "!" => "exclamation mark",
       "?" => "question mark", "'" => "apostrophe", '"' => "double quote"}.each do |mark, name|
        define_method(:"test_moves_a_trailing_#{name.tr(" ", "_")}_out_of_the_url") do
          assert_equal ["https://example.com/a", mark], Notes.trim_url("https://example.com/a#{mark}")
        end
      end

      def test_leaves_a_url_without_trailing_punctuation_alone
        assert_equal ["https://example.com/a?b=c#d", ""], Notes.trim_url("https://example.com/a?b=c#d")
        assert_equal ["https://example.com/", ""], Notes.trim_url("https://example.com/")
      end

      def test_keeps_punctuation_inside_the_url
        assert_equal ["https://example.com/a.b,c;d", ""], Notes.trim_url("https://example.com/a.b,c;d")
      end

      def test_moves_all_trailing_punctuation_out_in_its_original_order
        assert_equal ["https://example.com/a", "?!."], Notes.trim_url("https://example.com/a?!.")
        assert_equal ["https://example.com/a", %(.")], Notes.trim_url(%(https://example.com/a."))
      end

      def test_moves_an_unbalanced_closing_parenthesis_out
        assert_equal ["https://example.com/a", ")"], Notes.trim_url("https://example.com/a)")
      end

      def test_keeps_a_balanced_closing_parenthesis
        assert_equal [WIKIPEDIA, ""], Notes.trim_url(WIKIPEDIA)
      end

      def test_moves_an_unbalanced_closing_square_bracket_out
        assert_equal ["https://example.com/a", "]"], Notes.trim_url("https://example.com/a]")
        assert_equal ["https://example.com/", "]"], Notes.trim_url("https://example.com/]")
      end

      def test_keeps_balanced_square_brackets
        assert_equal ["https://example.com/a[1]", ""], Notes.trim_url("https://example.com/a[1]")
        assert_equal ["https://example.com/a[1]", "."], Notes.trim_url("https://example.com/a[1].")
      end

      def test_moves_only_the_unbalanced_square_bracket_out
        assert_equal ["https://example.com/a[1]", "]"], Notes.trim_url("https://example.com/a[1]]")
        assert_equal ["https://example.com/a", "]]"], Notes.trim_url("https://example.com/a]]")
      end

      def test_moves_square_brackets_parentheses_and_punctuation_out_in_any_combination
        assert_equal ["https://example.com/a", "])"], Notes.trim_url("https://example.com/a])")
        assert_equal ["https://example.com/a", ")]"], Notes.trim_url("https://example.com/a)]")
        assert_equal ["https://example.com/a", "]."], Notes.trim_url("https://example.com/a].")
        assert_equal ["https://example.com/a", ".])"], Notes.trim_url("https://example.com/a.])")
      end

      def test_counts_square_brackets_and_parentheses_separately
        assert_equal ["https://example.com/(a", "]"], Notes.trim_url("https://example.com/(a]")
        assert_equal ["https://example.com/[a", ")"], Notes.trim_url("https://example.com/[a)")
      end

      def test_an_opening_square_bracket_at_the_end_stays
        assert_equal ["https://example.com/a[", ""], Notes.trim_url("https://example.com/a[")
      end

      def test_moves_only_the_unbalanced_parenthesis_out
        assert_equal [WIKIPEDIA, ")"], Notes.trim_url("#{WIKIPEDIA})")
      end

      def test_moves_punctuation_and_parentheses_out_in_any_combination
        assert_equal ["https://example.com/a", ")."], Notes.trim_url("https://example.com/a).")
        assert_equal ["https://example.com/a", ".)"], Notes.trim_url("https://example.com/a.)")
        assert_equal ["https://example.com/a", ".)."], Notes.trim_url("https://example.com/a.).")
      end

      def test_keeps_a_balanced_parenthesis_when_punctuation_follows_it
        assert_equal [WIKIPEDIA, "."], Notes.trim_url("#{WIKIPEDIA}.")
        assert_equal [WIKIPEDIA, ")."], Notes.trim_url("#{WIKIPEDIA}).")
      end

      def test_counts_parentheses_across_the_whole_url
        assert_equal ["https://example.com/(a)(b)", ")"], Notes.trim_url("https://example.com/(a)(b))")
        assert_equal ["https://example.com/a)b", ")"], Notes.trim_url("https://example.com/a)b)")
      end

      def test_does_not_modify_its_argument
        url = +"https://example.com/a."
        Notes.trim_url(url)

        assert_equal "https://example.com/a.", url
      end
    end
  end
end
