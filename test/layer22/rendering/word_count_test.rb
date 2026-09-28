# frozen_string_literal: true

require "test_helper"

module Layer22
  module Rendering
    class WordCountTest < TestCase
      def test_count_counts_whitespace_separated_words
        assert_equal 5, WordCount.count("one two  three\nfour\tfive")
      end

      def test_count_ignores_tags
        assert_equal 3, WordCount.count(%(<p class="lead">one <em>two</em></p>\n<p>three</p>))
      end

      def test_count_ignores_script_contents
        assert_equal 1, WordCount.count("<script>var a = 1;\nvar b = 2;\n</script>\nword")
      end

      def test_count_ignores_style_contents
        assert_equal 1, WordCount.count("<style>p { color: red; }\n</style>\nword")
      end

      def test_count_ignores_comments
        assert_equal 1, WordCount.count("<!-- a hidden\nmultiline comment -->\nword")
      end

      def test_count_ignores_comments_that_contain_tags_and_angle_brackets
        assert_equal 1, WordCount.count("<!-- <b>hidden</b> if a > b -->\nword")
      end

      def test_count_ignores_scripts_that_contain_angle_brackets
        assert_equal 1, WordCount.count("<script>if (a > b) { run() }</script>\nword")
      end

      def test_count_removes_each_script_and_style_separately
        assert_equal 1, WordCount.count("<script>a</script> kept <script>b c</script>")
      end

      def test_count_ignores_attribute_values
        assert_equal 1, WordCount.count(%(<img src="/a.png" alt="many words in the alt text">\nword))
      end

      def test_count_of_empty_or_blank_html_is_zero
        assert_equal 0, WordCount.count("")
        assert_equal 0, WordCount.count(" \n<p></p>\n")
      end

      def test_count_joins_text_split_only_by_a_tag
        assert_equal 1, WordCount.count("a<br>b")
      end

      def test_count_counts_code_and_punctuation_tokens
        assert_equal 4, WordCount.count("<pre><code>puts &quot;hi&quot; - now</code></pre>")
      end
    end
  end
end
