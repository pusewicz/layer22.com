# frozen_string_literal: true

require "test_helper"

module Layer22
  module Content
    class FrontMatterTest < TestCase
      def test_parse_without_front_matter_returns_the_whole_content
        assert_equal [{}, "Just a body.\n"], FrontMatter.parse("Just a body.\n")
      end

      def test_parse_splits_front_matter_from_the_body
        front_matter, body = FrontMatter.parse("---\ntitle: Hi\ncount: 3\n---\nBody line.\n")

        assert_equal({"title" => "Hi", "count" => 3}, front_matter)
        assert_equal "Body line.\n", body
      end

      def test_parse_preserves_the_body_exactly
        body = "\nFirst.\n\n---\n\nAfter a rule.\n\n\nLast.\n"

        assert_equal body, FrontMatter.parse("---\ntitle: Hi\n---\n#{body}").last
      end

      def test_parse_stops_at_the_first_closing_delimiter
        front_matter, body = FrontMatter.parse("---\na: 1\n---\nx\n---\nb: 2\n---\n")

        assert_equal({"a" => 1}, front_matter)
        assert_equal "x\n---\nb: 2\n---\n", body
      end

      def test_parse_treats_unterminated_front_matter_as_body
        content = "---\ntitle: Hi\nno closing delimiter\n"

        assert_equal [{}, content], FrontMatter.parse(content)
      end

      def test_parse_accepts_empty_front_matter
        assert_equal [{}, "body\n"], FrontMatter.parse("---\n---\nbody\n")
      end

      def test_parse_accepts_front_matter_that_is_only_a_comment
        assert_equal [{}, "body\n"], FrontMatter.parse("---\n# nothing here\n---\nbody\n")
      end

      def test_parse_returns_an_empty_body_when_the_file_ends_at_the_delimiter
        assert_equal [{"a" => 1}, ""], FrontMatter.parse("---\na: 1\n---\n")
        assert_equal [{"a" => 1}, ""], FrontMatter.parse("---\na: 1\n---")
      end

      def test_parse_allows_trailing_whitespace_after_delimiters
        assert_equal [{"a" => 1}, "x\n"], FrontMatter.parse("---  \na: 1\n---\t\nx\n")
      end

      def test_parse_requires_front_matter_to_start_on_the_first_line
        content = "\n---\na: 1\n---\nx\n"

        assert_equal [{}, content], FrontMatter.parse(content)
      end

      def test_parse_does_not_mistake_a_longer_dash_run_for_a_delimiter
        content = "----\na: 1\n----\nx\n"

        assert_equal [{}, content], FrontMatter.parse(content)
      end

      def test_parse_reads_dates_and_times
        front_matter, = FrontMatter.parse("---\nday: 2021-05-01\nat: 2021-05-01 09:30:00 +0200\n---\n")

        assert_instance_of Date, front_matter["day"]
        assert_equal Date.new(2021, 5, 1), front_matter["day"]
        assert_instance_of Time, front_matter["at"]
        assert_equal Time.utc(2021, 5, 1, 7, 30), front_matter["at"]
      end

      def test_parse_reads_nested_values
        front_matter, = FrontMatter.parse("---\nlink:\n  url: https://example.test\ntags: [a, b]\n---\n")

        assert_equal({"url" => "https://example.test"}, front_matter["link"])
        assert_equal %w[a b], front_matter["tags"]
      end

      def test_parse_refuses_arbitrary_yaml_objects
        assert_raises(Psych::DisallowedClass) { FrontMatter.parse("---\npattern: !ruby/regexp /x/\n---\n") }
      end

      def test_parse_raises_for_invalid_yaml
        assert_raises(Psych::SyntaxError) { FrontMatter.parse("---\ntags: [unclosed\n---\nbody\n") }
      end

      def test_parse_transcodes_content_to_utf8
        content = "---\ntitle: caf\xE9\n---\nna\xEFve\n".dup.force_encoding(Encoding::ISO_8859_1)
        front_matter, body = FrontMatter.parse(content)

        assert_equal "café", front_matter["title"]
        assert_equal "naïve\n", body
        assert_equal Encoding::UTF_8, body.encoding
      end

      def test_parse_returns_a_utf8_body_for_ascii_content
        _, body = FrontMatter.parse("---\na: 1\n---\nbody".encode(Encoding::US_ASCII))

        assert_equal Encoding::UTF_8, body.encoding
      end

      def test_read_returns_the_file_as_utf8
        with_site({"post.md" => "---\ntitle: Café\n---\n"}) do |dir|
          content = FrontMatter.read(File.join(dir, "post.md"))

          assert_equal "---\ntitle: Café\n---\n", content
          assert_equal Encoding::UTF_8, content.encoding
        end
      end

      def test_read_raises_for_a_missing_file
        assert_raises(Errno::ENOENT) { FrontMatter.read("/nonexistent/post.md") }
      end

      def test_text_decodes_html_entities
        assert_equal "Year — in review", FrontMatter.text("Year &mdash; in review")
        assert_equal "Fish & chips <3", FrontMatter.text("Fish &amp; chips &lt;3")
      end

      def test_text_leaves_plain_strings_alone
        assert_equal "Hello, World", FrontMatter.text("Hello, World")
        assert_equal "Café notes", FrontMatter.text("Café notes")
      end

      def test_text_returns_nil_for_nil
        assert_nil FrontMatter.text(nil)
      end

      def test_text_returns_an_empty_string_for_an_empty_string
        assert_equal "", FrontMatter.text("")
      end

      def test_text_converts_non_strings
        assert_equal "2021", FrontMatter.text(2021)
      end

      def test_text_strips_markup
        assert_equal "bold & plain", FrontMatter.text("<b>bold</b> &amp; plain")
      end

      def test_list_reads_a_singular_key_as_one_value
        assert_equal ["ruby"], FrontMatter.list({"tag" => "ruby"}, "tag", "tags")
      end

      def test_list_keeps_whitespace_inside_a_singular_value
        assert_equal ["ruby on rails"], FrontMatter.list({"tag" => "ruby on rails"}, "tag", "tags")
      end

      def test_list_reads_an_array_under_the_singular_key
        assert_equal %w[a b], FrontMatter.list({"tag" => %w[a b]}, "tag", "tags")
      end

      def test_list_prefers_the_singular_key_over_the_plural
        assert_equal ["one"], FrontMatter.list({"tag" => "one", "tags" => %w[two three]}, "tag", "tags")
      end

      def test_list_treats_an_empty_singular_key_as_an_empty_list
        assert_equal [], FrontMatter.list({"tag" => nil, "tags" => %w[ignored]}, "tag", "tags")
      end

      def test_list_splits_a_plural_string_on_whitespace
        assert_equal %w[ruby Café rails], FrontMatter.list({"tags" => "ruby  Café\nrails"}, "tag", "tags")
      end

      def test_list_reads_a_plural_array
        assert_equal %w[ruby rails], FrontMatter.list({"tags" => %w[ruby rails]}, "tag", "tags")
      end

      def test_list_drops_nils_and_stringifies_other_values
        assert_equal %w[ruby 3 2021-05-01], FrontMatter.list({"tags" => ["ruby", nil, 3, Date.new(2021, 5, 1)]}, "tag", "tags")
        assert_equal %w[2021], FrontMatter.list({"tag" => 2021}, "tag", "tags")
      end

      def test_list_is_empty_when_neither_key_is_present
        assert_equal [], FrontMatter.list({}, "tag", "tags")
      end

      def test_list_ignores_a_plural_value_that_is_neither_string_nor_array
        assert_equal [], FrontMatter.list({"tags" => 5}, "tag", "tags")
        assert_equal [], FrontMatter.list({"tags" => {"a" => 1}}, "tag", "tags")
        assert_equal [], FrontMatter.list({"tags" => nil}, "tag", "tags")
      end

      def test_list_works_for_categories
        assert_equal ["life"], FrontMatter.list({"category" => "life"}, "category", "categories")
        assert_equal %w[a b], FrontMatter.list({"categories" => "a b"}, "category", "categories")
      end
    end
  end
end
