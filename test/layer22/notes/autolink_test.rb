# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class AutolinkTest < TestCase
      WIKIPEDIA = "https://en.wikipedia.org/wiki/Ruby_(programming_language)"

      def test_wraps_a_bare_url_in_angle_brackets
        assert_equal "See <https://example.com/a?b=c#d> today", Notes.autolink("See https://example.com/a?b=c#d today")
      end

      def test_wraps_a_url_that_is_the_whole_text
        assert_equal "<https://example.com>", Notes.autolink("https://example.com")
      end

      def test_wraps_http_urls
        assert_equal "<http://example.com/>", Notes.autolink("http://example.com/")
      end

      def test_wraps_every_url_including_on_separate_lines
        assert_equal "a <https://a.example>\nb <https://b.example> c <https://c.example>",
          Notes.autolink("a https://a.example\nb https://b.example c https://c.example")
      end

      def test_moves_trailing_punctuation_outside_the_brackets
        assert_equal "See <https://example.com/a>.", Notes.autolink("See https://example.com/a.")
        assert_equal "<https://a.example>, and <https://b.example>!", Notes.autolink("https://a.example, and https://b.example!")
        assert_equal %(<https://example.com/a>?"), Notes.autolink(%(https://example.com/a?"))
      end

      def test_keeps_the_parentheses_of_a_url_that_balances_them
        assert_equal "(<#{WIKIPEDIA}>).", Notes.autolink("(#{WIKIPEDIA}).")
        assert_equal "<http://example.com/x_(y)_z>", Notes.autolink("http://example.com/x_(y)_z")
      end

      def test_moves_a_parenthesis_that_closes_the_sentence_outside_the_brackets
        assert_equal "(<https://example.com/x>)", Notes.autolink("(https://example.com/x)")
      end

      def test_leaves_text_without_urls_alone
        assert_equal "Nothing to link, not even example.com", Notes.autolink("Nothing to link, not even example.com")
        assert_equal "", Notes.autolink("")
      end

      def test_leaves_urls_in_a_fenced_code_block_alone
        text = "```\nhttps://example.com\n```"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_urls_in_a_fenced_code_block_with_a_language_alone
        text = "```ruby\nget \"https://example.com\"\n```"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_urls_in_a_tilde_fence_alone
        text = "~~~\nhttps://example.com\n~~~"

        assert_equal text, Notes.autolink(text)
      end

      def test_links_urls_after_a_closed_code_block
        assert_equal "```\nhttps://a.example\n```\nafter <https://b.example>", Notes.autolink("```\nhttps://a.example\n```\nafter https://b.example")
        assert_equal "~~~\nhttps://a.example\n~~~\n<https://b.example>", Notes.autolink("~~~\nhttps://a.example\n~~~\nhttps://b.example")
      end

      def test_a_longer_fence_is_not_closed_by_a_shorter_one
        text = "````\n```\nhttps://a.example\n```\n````\nhttps://b.example"

        assert_equal "````\n```\nhttps://a.example\n```\n````\n<https://b.example>", Notes.autolink(text)
      end

      def test_a_tilde_fence_is_not_closed_by_a_backtick_fence
        text = "~~~\nhttps://a.example\n```\nhttps://b.example\n~~~"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_urls_in_an_indented_fence_alone
        text = "  ```\nhttps://example.com\n  ```"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_urls_in_a_code_span_alone
        assert_equal "`https://a.example` and <https://b.example>", Notes.autolink("`https://a.example` and https://b.example")
      end

      def test_leaves_urls_in_a_double_backtick_code_span_alone
        assert_equal "``a ` https://a.example`` <https://b.example>", Notes.autolink("``a ` https://a.example`` https://b.example")
      end

      def test_leaves_the_target_of_a_markdown_link_alone
        assert_equal "[the post](https://a.example) <https://b.example>", Notes.autolink("[the post](https://a.example) https://b.example")
      end

      def test_leaves_the_target_of_a_markdown_image_alone
        text = "![chart](https://example.com/chart.png)"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_a_markdown_link_whose_text_is_the_url_alone
        text = "[https://example.com](https://example.com)"

        assert_equal text, Notes.autolink(text)
        assert_equal "[https://a.example](https://b.example) <https://c.example>", Notes.autolink("[https://a.example](https://b.example) https://c.example")
      end

      def test_leaves_a_markdown_link_with_a_url_in_its_text_alone
        text = "[see https://example.com/a for more](https://example.com/b)"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_a_markdown_image_with_a_url_in_its_alt_text_alone
        text = "![chart from https://example.com](https://example.com/chart.png)"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_a_markdown_link_with_a_title_alone
        text = %([the post](https://example.com/post "A title with https://example.com"))

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_a_markdown_link_to_a_url_with_parentheses_alone
        text = "[Ruby](#{WIKIPEDIA}) and [more](https://example.com)"

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_a_markdown_link_in_parentheses_alone
        assert_equal "([the post](https://example.com/post)).", Notes.autolink("([the post](https://example.com/post)).")
      end

      def test_links_bare_urls_around_markdown_links
        assert_equal "<https://a.example> [b](https://b.example), [c](https://c.example) and <https://d.example>.",
          Notes.autolink("https://a.example [b](https://b.example), [c](https://c.example) and https://d.example.")
      end

      def test_links_a_bare_url_in_square_brackets
        assert_equal "[see <https://example.com>]", Notes.autolink("[see https://example.com]")
        assert_equal "[<https://example.com>]", Notes.autolink("[https://example.com]")
      end

      def test_keeps_balanced_square_brackets_in_a_url
        assert_equal "<https://example.com/a[1]>", Notes.autolink("https://example.com/a[1]")
        assert_equal "<https://example.com/a[1]>.", Notes.autolink("https://example.com/a[1].")
        assert_equal "[<https://example.com/a[1]>]", Notes.autolink("[https://example.com/a[1]]")
      end

      def test_leaves_an_existing_autolink_alone
        assert_equal "<https://example.com>", Notes.autolink("<https://example.com>")
        assert_equal "<https://example.com>.", Notes.autolink("<https://example.com>.")
      end

      def test_leaves_urls_in_quoted_attributes_alone
        text = %(<a href="https://example.com">x</a> <img src='https://example.com/i.png'>)

        assert_equal text, Notes.autolink(text)
      end

      def test_leaves_urls_after_an_equals_sign_alone
        assert_equal "src=https://example.com", Notes.autolink("src=https://example.com")
      end

      def test_leaves_quoted_urls_alone
        assert_equal %("https://example.com"), Notes.autolink(%("https://example.com"))
        assert_equal "'https://example.com'", Notes.autolink("'https://example.com'")
      end

      def test_links_the_url_of_a_reference_definition
        assert_equal "[ref]: <https://example.com>", Notes.autolink("[ref]: https://example.com")
      end

      def test_links_a_url_after_an_unclosed_backtick
        assert_equal "a `unclosed <https://example.com>", Notes.autolink("a `unclosed https://example.com")
      end

      def test_links_a_url_in_an_unterminated_fence
        assert_equal "```\nunterminated <https://example.com>", Notes.autolink("```\nunterminated https://example.com")
      end

      def test_is_idempotent
        once = Notes.autolink("See https://a.example/x, `https://b.example` and [c](https://c.example).")

        assert_equal once, Notes.autolink(once)
      end
    end
  end
end
