# frozen_string_literal: true

require "test_helper"

module Layer22
  module Generators
    class FeedsTest < TestCase
      def test_absolutize_makes_root_relative_links_absolute
        html = %(<a href="/about">About</a> <a href="/2021/post/">Post</a>)

        assert_equal %(<a href="https://example.test/about">About</a> <a href="https://example.test/2021/post/">Post</a>),
          Feeds.absolutize(html, site_url: "https://example.test")
      end

      def test_absolutize_makes_root_relative_images_absolute
        assert_equal %(<img src="https://example.test/images/a.png" alt="A">),
          Feeds.absolutize(%(<img src="/images/a.png" alt="A">), site_url: "https://example.test")
      end

      def test_absolutize_handles_href_and_src_in_the_same_tag
        assert_equal %(<a href="https://example.test/big.png"><img src="https://example.test/small.png"></a>),
          Feeds.absolutize(%(<a href="/big.png"><img src="/small.png"></a>), site_url: "https://example.test")
      end

      def test_absolutize_makes_the_site_root_absolute
        assert_equal %(<a href="https://example.test/">Home</a>),
          Feeds.absolutize(%(<a href="/">Home</a>), site_url: "https://example.test")
      end

      def test_absolutize_leaves_other_urls_alone
        html = %(<a href="https://other.test/x">a</a> <a href="#top">b</a> <a href="relative/page">c</a> <a href="mailto:a@b.test">d</a>)

        assert_equal html, Feeds.absolutize(html, site_url: "https://example.test")
      end

      def test_absolutize_requires_the_site_url
        assert_raises(ArgumentError) { Feeds.absolutize("<p></p>") }
      end

      def test_plain_text_decodes_entities
        assert_equal "Fish & chips — <ok>", Feeds.plain_text("<p>Fish &amp; chips &mdash; &lt;ok&gt;</p>")
      end

      def test_plain_text_separates_block_elements_with_a_space
        assert_equal "one two three", Feeds.plain_text("<p>one</p><p>two</p><div>three</div>")
      end

      def test_plain_text_separates_list_items_and_headings
        assert_equal "Title first second", Feeds.plain_text("<h2>Title</h2><ul><li>first</li><li>second</li></ul>")
      end

      def test_plain_text_separates_table_cells
        assert_equal "a b c", Feeds.plain_text("<table><tr><td>a</td><td>b</td></tr><tr><td>c</td></tr></table>")
      end

      def test_plain_text_treats_a_line_break_as_a_word_boundary
        assert_equal "a b", Feeds.plain_text("a<br>b")
      end

      def test_plain_text_joins_text_split_only_by_inline_elements
        assert_equal "abcdef", Feeds.plain_text("<p>ab<em>cd</em>ef</p>")
        assert_equal "Hello bold world", Feeds.plain_text("<p>Hello <strong>bold</strong> world</p>")
      end

      def test_plain_text_skips_script_style_and_template_contents
        html = "<p>keep</p><script>var hidden = 1;</script><style>p { color: red }</style><template>tpl</template><p>this</p>"

        assert_equal "keep this", Feeds.plain_text(html)
      end

      def test_plain_text_skips_scripts_nested_in_inline_elements
        assert_equal "ab", Feeds.plain_text("<span>a<script>x</script>b</span>")
      end

      def test_plain_text_skips_comments
        assert_equal "ab", Feeds.plain_text("<p>a<!-- hidden -->b</p>")
      end

      def test_plain_text_collapses_whitespace
        assert_equal "a b c", Feeds.plain_text("  a \n\n b\t\tc \n")
      end

      def test_plain_text_keeps_preformatted_text_on_one_line
        assert_equal "before puts 1 after", Feeds.plain_text("before<pre>puts\n  1</pre>after")
      end

      def test_plain_text_of_empty_html_is_empty
        assert_equal "", Feeds.plain_text("")
        assert_equal "", Feeds.plain_text("<p> </p>")
      end

      def test_truncate_leaves_text_within_the_length_alone
        assert_equal "short", Feeds.truncate("short", 10)
        assert_equal "exactly ten", Feeds.truncate("exactly ten", 11)
      end

      def test_truncate_cuts_text_one_over_the_length
        assert_equal "abcdefg...", Feeds.truncate("abcdefghijk", 10)
      end

      def test_truncate_result_is_exactly_the_length
        assert_equal 10, Feeds.truncate("a" * 50, 10).length
        assert_equal "aaaaaaa...", Feeds.truncate("a" * 50, 10)
      end

      def test_truncate_counts_characters_not_bytes
        assert_equal "éé...", Feeds.truncate("éééééé", 5)
        assert_equal "ééééé", Feeds.truncate("ééééé", 5)
      end

      def test_truncate_of_empty_text_is_empty
        assert_equal "", Feeds.truncate("", 5)
      end

      def test_truncate_to_three_characters_leaves_only_the_ellipsis
        assert_equal "...", Feeds.truncate("abcdef", 3)
      end
    end
  end
end
