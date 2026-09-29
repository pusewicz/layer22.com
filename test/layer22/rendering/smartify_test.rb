# frozen_string_literal: true

require "test_helper"

module Layer22
  module Rendering
    class SmartifyTest < TestCase
      def test_call_curls_double_quotes
        assert_equal "“Hello” said the site", Smartify.call(%("Hello" said the site))
      end

      def test_call_curls_single_quotes_and_apostrophes
        assert_equal "It’s ‘quoted’", Smartify.call("It's 'quoted'")
      end

      def test_call_turns_double_hyphens_into_en_dashes_and_triple_into_em_dashes
        assert_equal "2019–2021 — and on", Smartify.call("2019--2021 --- and on")
      end

      def test_call_turns_three_dots_into_an_ellipsis
        assert_equal "Wait…", Smartify.call("Wait...")
      end

      def test_call_leaves_plain_text_alone
        assert_equal "Hello, World", Smartify.call("Hello, World")
      end

      def test_call_keeps_unicode
        assert_equal "Café — ‘naïve’", Smartify.call("Café --- 'naïve'")
      end

      def test_call_strips_surrounding_whitespace
        assert_equal "“padded”", Smartify.call(%(  "padded"\n))
      end

      def test_call_returns_an_empty_string_for_empty_input
        assert_equal "", Smartify.call("")
      end

      def test_call_returns_utf8_text
        assert_equal Encoding::UTF_8, Smartify.call("It's").encoding
      end
    end
  end
end
