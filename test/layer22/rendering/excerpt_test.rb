# frozen_string_literal: true

require "test_helper"

module Layer22
  module Rendering
    class ExcerptTest < TestCase
      def test_from_markdown_returns_the_first_block
        assert_equal "First paragraph.", Excerpt.from_markdown("First paragraph.\n\nSecond paragraph.\n")
      end

      def test_from_markdown_joins_the_lines_of_the_first_block
        assert_equal "Line one line two", Excerpt.from_markdown("Line one\nline two\n\nNext.\n")
      end

      def test_from_markdown_treats_a_whitespace_only_line_as_a_block_break
        assert_equal "one", Excerpt.from_markdown("one\n   \ntwo\n")
      end

      def test_from_markdown_skips_leading_blank_lines
        assert_equal "First.", Excerpt.from_markdown("\n\n  First.\n\nSecond.\n")
      end

      def test_from_markdown_strips_markup
        markdown = "**Bold**, *italic*, `code`, [a link](https://example.test/) and ![alt text](x.png) done.\n"

        assert_equal "Bold, italic, code, a link and done.", Excerpt.from_markdown(markdown)
      end

      def test_from_markdown_strips_heading_markup
        assert_equal "Heading", Excerpt.from_markdown("# Heading\n\nBody.\n")
      end

      def test_from_markdown_strips_raw_html_tags
        assert_equal "raw and more", Excerpt.from_markdown("<div>raw</div> and more\n\nx\n")
      end

      def test_from_markdown_normalises_whitespace
        assert_equal "spaced out text", Excerpt.from_markdown("spaced    out\t text  \n")
      end

      def test_from_markdown_applies_smart_punctuation
        assert_equal "“quoted” – it’s…", Excerpt.from_markdown(%("quoted" -- it's...\n))
      end

      def test_from_markdown_carries_reference_link_definitions_into_the_excerpt
        markdown = "See [the docs][docs] and [ref] too.\n\nMore text.\n\n[docs]: https://example.test/docs\n[ref]: https://example.test/ref \"Title\"\n"

        assert_equal "See the docs and ref too.", Excerpt.from_markdown(markdown)
      end

      def test_from_markdown_leaves_unresolved_references_as_text
        assert_equal "See [nowhere] here.", Excerpt.from_markdown("See [nowhere] here.\n")
      end

      def test_from_markdown_recognises_definitions_indented_up_to_three_spaces
        markdown = "A [ref] link.\n\nText.\n\n   [ref]: https://example.test/\n"

        assert_equal "A ref link.", Excerpt.from_markdown(markdown)
      end

      def test_from_markdown_ignores_definitions_indented_as_code
        markdown = "A [ref] link.\n\nText.\n\n    [ref]: https://example.test/\n"

        assert_equal "A [ref] link.", Excerpt.from_markdown(markdown)
      end

      def test_from_markdown_returns_an_empty_string_for_empty_input
        assert_equal "", Excerpt.from_markdown("")
        assert_equal "", Excerpt.from_markdown("  \n\n \n")
      end

      def test_from_markdown_of_only_definitions_is_empty
        assert_equal "", Excerpt.from_markdown("[ref]: https://example.test/\n")
      end

      def test_from_markdown_of_a_code_block_is_its_text
        assert_equal "git status", Excerpt.from_markdown("```sh\ngit status\n```\n")
      end
    end
  end
end
