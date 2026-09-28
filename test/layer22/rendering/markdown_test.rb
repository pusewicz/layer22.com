# frozen_string_literal: true

require "test_helper"

module Layer22
  module Rendering
    class MarkdownTest < TestCase
      def test_render_returns_an_empty_string_for_empty_input
        assert_equal "", Markdown.render("")
      end

      def test_render_wraps_a_fenced_block_in_rouge_markup
        code = highlighted(Markdown.render(%(```ruby\nputs "hi"\n```\n)), "ruby")

        assert_equal %(puts "hi"\n), code.text
        assert_operator code.css("span").size, :>, 0
      end

      def test_render_produces_the_kramdown_rouge_structure
        html = parse_html(Markdown.render("```ruby\nx = 1\n```\n"))

        assert_equal 1, html.css("div.language-ruby.highlighter-rouge > div.highlight > pre.highlight > code").size
        assert_equal 1, html.css("pre").size
      end

      def test_render_uses_the_fence_language_for_the_wrapper_class
        assert_equal 1, parse_html(Markdown.render("```sh\nls\n```\n")).css("div.language-sh.highlighter-rouge").size
        assert_equal 1, parse_html(Markdown.render("```yaml\na: 1\n```\n")).css("div.language-yaml.highlighter-rouge").size
      end

      def test_render_escapes_html_inside_highlighted_code
        code = highlighted(Markdown.render("```html\n<b>bold</b> & more\n```\n"), "html")

        assert_equal "<b>bold</b> & more\n", code.text
        assert_includes code.inner_html, "&lt;"
        assert_includes code.inner_html, "&amp;"
      end

      def test_render_leaves_an_unknown_language_as_a_plain_code_block
        assert_equal %(<pre><code class="language-klingon">qapla'\n</code></pre>\n), Markdown.render("```klingon\nqapla'\n```\n")
      end

      def test_render_highlights_a_fence_without_a_language_as_plaintext
        code = highlighted(Markdown.render("```\nplain text\n```\n"), "plaintext")

        assert_equal "plain text\n", code.text
      end

      def test_render_treats_an_indented_block_as_plaintext_code
        code = highlighted(Markdown.render("Intro\n\n    indented <b>code</b>\n"), "plaintext")

        assert_equal "indented <b>code</b>\n", code.text
      end

      def test_render_marks_inline_code_like_kramdown
        assert_equal %(<p>Call <code class="language-plaintext highlighter-rouge">puts</code> now</p>\n), Markdown.render("Call `puts` now\n")
      end

      def test_render_does_not_mark_the_code_inside_a_block
        html = parse_html(Markdown.render("```klingon\nqapla'\n```\n"))

        assert_equal "language-klingon", html.at_css("pre > code")["class"]
        assert_equal 1, html.css("code").size
      end

      def test_render_gives_headings_ids
        html = Markdown.render("# One\n\n## Two words\n\n### Three\n")

        assert_equal %(<h1 id="one">One</h1>\n<h2 id="two-words">Two words</h2>\n<h3 id="three">Three</h3>\n), html
      end

      def test_render_gives_every_heading_level_an_id
        markdown = (1..6).map { |level| "#{"#" * level} Level #{level}\n" }.join("\n")

        assert_equal %w[level-1 level-2 level-3 level-4 level-5 level-6], heading_ids(markdown)
      end

      def test_render_numbers_repeated_headings
        ids = heading_ids("## Setup\n\n## Setup\n\n## Setup\n")

        assert_equal %w[setup setup-1 setup-2], ids
      end

      def test_render_counts_repeats_across_heading_levels
        assert_equal %w[intro intro-1], heading_ids("# Intro\n\n### Intro\n")
      end

      def test_render_strips_leading_digits_and_punctuation_from_heading_ids
        assert_equal %w[getting-started fast-2-furious], heading_ids("### 1. Getting started!\n\n## 2 Fast 2 Furious\n")
      end

      def test_render_falls_back_to_section_when_a_heading_has_no_usable_text
        assert_equal %w[section section-1 section-2], heading_ids("## 42\n\n## !!!\n\n## 2021\n")
      end

      def test_render_drops_characters_outside_ascii_from_heading_ids_like_kramdown
        assert_equal %w[caf foo---bar], heading_ids("## Café\n\n## Foo - Bar\n")
      end

      def test_render_builds_heading_ids_from_the_text_of_inline_markup
        assert_equal %w[code-and-em], heading_ids("## `code` and *em*\n")
      end

      def test_render_keeps_an_existing_heading_id
        assert_equal %(<h2 id="custom">Original title</h2>\n), Markdown.render(%(<h2 id="custom">Original title</h2>\n))
      end

      def test_render_lazy_loads_markdown_images
        assert_equal %(<p><img src="/x.png" alt="An image" loading="lazy"></p>\n), Markdown.render("![An image](/x.png)\n")
      end

      def test_render_lazy_loads_raw_html_images_without_a_loading_attribute
        html = parse_html(Markdown.render(%(<img src="/a.png">\n)))

        assert_equal "lazy", html.at_css("img")["loading"]
      end

      def test_render_keeps_an_existing_loading_attribute
        html = parse_html(Markdown.render(%(<img src="/a.png" loading="eager">\n\n<img src="/b.png" loading="lazy">\n)))

        assert_equal %w[eager lazy], html.css("img").map { |img| img["loading"] }
      end

      def test_render_applies_smart_punctuation
        html = Markdown.render(%("quoted" -- dash --- em... 'single' don't\n))

        assert_equal "<p>“quoted” – dash — em… ‘single’ don’t</p>\n", html
      end

      def test_render_leaves_punctuation_in_code_alone
        assert_includes Markdown.render(%(`"a" -- b...`\n)), %("a" -- b...)
      end

      def test_render_passes_raw_html_through
        html = Markdown.render(%(<div class="custom">Raw</div>\n\n<script>alert(1)</script>\n\n<iframe src="https://example.test/embed"></iframe>\n))

        assert_includes html, %(<div class="custom">Raw</div>)
        assert_includes html, "<script>alert(1)</script>"
        assert_includes html, %(<iframe src="https://example.test/embed"></iframe>)
      end

      def test_render_does_not_autolink_bare_urls
        assert_equal "<p>see https://example.test/page</p>\n", Markdown.render("see https://example.test/page\n")
      end

      def test_render_keeps_explicit_links
        assert_equal %(<p><a href="https://example.test/">a link</a></p>\n), Markdown.render("[a link](https://example.test/)\n")
      end

      def test_render_keeps_soft_line_breaks_as_newlines
        assert_equal "<p>one\ntwo</p>\n", Markdown.render("one\ntwo\n")
      end

      def test_render_returns_utf8
        assert_equal Encoding::UTF_8, Markdown.render("# Hi\n").encoding
        assert_equal Encoding::UTF_8, Markdown.render("```ruby\nputs 1\n```\n").encoding
      end

      def test_render_keeps_unicode_text
        assert_equal "<p>café ☕ 日本語</p>\n", Markdown.render("café ☕ 日本語\n")
      end

      def test_render_accepts_input_in_other_encodings
        latin1 = "caf\xE9\n".dup.force_encoding(Encoding::ISO_8859_1)
        ascii = "plain\n".encode(Encoding::US_ASCII)

        assert_equal "<p>café</p>\n", Markdown.render(latin1)
        assert_equal "<p>plain</p>\n", Markdown.render(ascii)
      end

      private

      def highlighted(html, language)
        code = parse_html(html).at_css("div.language-#{language}.highlighter-rouge > div.highlight > pre.highlight > code")
        assert code, "no highlighted #{language} block in #{html}"
        code
      end

      def heading_ids(markdown)
        parse_html(Markdown.render(markdown)).css("h1, h2, h3, h4, h5, h6").map { |heading| heading["id"] }
      end
    end
  end
end
