# frozen_string_literal: true

require "test_helper"
require_relative "../local_time_assertions"

module Layer22
  module Content
    class PostTest < TestCase
      include LocalTimeAssertions

      def self.fixture_posts
        @fixture_posts ||= Dir.chdir(FIXTURE_ROOT) { Post.load_all("_posts", words_per_minute: 100.0) }.to_h { |post| [post.slug, post] }
      end

      def test_load_all_reads_the_fixture_posts_in_path_order
        assert_equal %w[hello-world review cafe], fixture_posts.keys
      end

      def test_hello_world_takes_its_identity_from_the_filename
        post = fixture_posts.fetch("hello-world")

        assert_equal "Hello, World", post.title
        assert_equal "hello-world", post.slug
        assert_equal "/hello-world", post.permalink
        assert_equal "_posts/2019-03-14-hello-world.md", post.relative_path
        assert_local_time "2019-03-14 00:00:00 +0100", post.date
      end

      def test_hello_world_reads_its_taxonomy
        post = fixture_posts.fetch("hello-world")

        assert_equal %w[ruby rails], post.tags
        assert_equal %w[code], post.categories
        assert_equal [], post.redirect_from
      end

      def test_hello_world_describes_itself_with_its_first_paragraph
        assert_equal "This is the first paragraph of the first post. It has a reference link and inline code.",
          fixture_posts.fetch("hello-world").description
      end

      def test_hello_world_renders_its_body
        html = fixture_posts.fetch("hello-world").body_html

        assert_includes html, '<a href="https://example.test/reference">a reference link</a>'
        assert_includes html, '<h2 id="setup">Setup</h2>'
        assert_includes html, '<h2 id="setup-1">Setup</h2>'
        assert_includes html, '<div class="language-ruby highlighter-rouge">'
        assert_includes html, %(<pre><code class="language-klingon">qapla'\n</code></pre>)
        assert_includes html, '<img src="/images/notes/wide.png" alt="A diagram" loading="lazy">'
      end

      def test_hello_world_counts_the_words_of_its_rendered_body
        post = fixture_posts.fetch("hello-world")

        assert_equal 35, post.word_count
        assert_equal 1, post.reading_time
      end

      def test_hello_world_uses_the_last_modified_time_from_its_front_matter
        assert_local_time "2019-04-01 10:00:00 +0200", fixture_posts.fetch("hello-world").last_modified_at
      end

      def test_review_converts_its_date_to_the_sites_timezone
        date = fixture_posts.fetch("review").date

        assert_local_time "2021-01-01 00:30:00 +0100", date
        assert_equal 2021, date.year
      end

      def test_review_slug_override_replaces_the_filename_slug
        post = fixture_posts.fetch("review")

        assert_equal "review", post.slug
        assert_equal "/review", post.permalink
        assert_equal "_posts/2020-12-31-year-in-review.markdown", post.relative_path
      end

      def test_review_decodes_entities_in_its_title
        assert_equal "Year — in review", fixture_posts.fetch("review").title
      end

      def test_review_reads_singular_tag_and_category
        post = fixture_posts.fetch("review")

        assert_equal %w[ruby], post.tags
        assert_equal %w[life], post.categories
      end

      def test_review_prefers_its_front_matter_description
        assert_equal "What happened in 2020.", fixture_posts.fetch("review").description
      end

      def test_review_lists_its_redirects
        assert_equal ["/old-review", "/2020/old-review.html"], fixture_posts.fetch("review").redirect_from
      end

      def test_review_converts_last_modified_at_to_the_local_zone
        assert_local_time "2021-01-05 09:00:00 +0100", fixture_posts.fetch("review").last_modified_at
      end

      def test_review_renders_smart_punctuation_and_raw_html
        html = fixture_posts.fetch("review").body_html

        assert_includes html, "<p>Written late on New Year’s Eve, UTC: “quoted” text – and an ellipsis…</p>"
        assert_includes html, '<div class="custom">Raw HTML stays.</div>'
        assert_equal 16, fixture_posts.fetch("review").word_count
      end

      def test_cafe_splits_a_whitespace_separated_tag_string
        assert_equal %w[ruby Café], fixture_posts.fetch("cafe").tags
        assert_equal [], fixture_posts.fetch("cafe").categories
      end

      def test_cafe_keeps_unicode_in_its_title_and_uses_the_summer_offset
        post = fixture_posts.fetch("cafe")

        assert_equal "Café notes", post.title
        assert_local_time "2021-06-01 00:00:00 +0200", post.date
      end

      def test_cafe_renders_an_indented_code_block
        post = fixture_posts.fetch("cafe")

        assert_includes post.body_html, '<div class="language-plaintext highlighter-rouge">'
        assert_equal "Short.", post.description
        assert_equal 4, post.word_count
      end

      def test_slug_drops_only_the_leading_date_from_the_filename
        post = load_post("2021-02-03-2021-recap.md", "Body.")

        assert_equal "2021-recap", post.slug
        assert_equal "/2021-recap", post.permalink
      end

      def test_date_comes_from_the_filename_without_front_matter
        post = load_post("2021-02-03-x.md", "Body.")

        assert_local_time "2021-02-03 00:00:00 +0100", post.date
      end

      def test_front_matter_date_overrides_the_filename_date_but_not_the_slug
        post = load_post("2019-01-01-x.md", "---\ndate: 2020-07-04 15:00:00 +0000\n---\nBody.")

        assert_local_time "2020-07-04 17:00:00 +0200", post.date
        assert_equal "x", post.slug
      end

      def test_date_can_come_from_front_matter_alone
        post = load_post("undated-name.md", "---\ndate: 2021-02-03\n---\nBody.")

        assert_equal "undated-name", post.slug
        assert_local_time "2021-02-03 00:00:00 +0100", post.date
      end

      def test_title_falls_back_to_the_slug
        assert_equal "untitled", load_post("2021-02-03-untitled.md", "Body.").title
      end

      def test_description_falls_back_to_the_first_paragraph
        post = load_post("2021-02-03-x.md", "First *paragraph* here.\nStill first.\n\nSecond paragraph.")

        assert_equal "First paragraph here. Still first.", post.description
      end

      def test_description_is_empty_for_an_empty_body
        assert_equal "", load_post("2021-02-03-x.md", "---\ntitle: T\n---\n").description
      end

      def test_plural_tags_and_categories_accept_arrays_and_strings
        post = load_post("2021-02-03-x.md", "---\ntags: [a, b]\ncategories: one two\n---\nBody.")

        assert_equal %w[a b], post.tags
        assert_equal %w[one two], post.categories
      end

      def test_redirect_from_accepts_a_single_string
        assert_equal ["/old"], load_post("2021-02-03-x.md", "---\nredirect_from: /old\n---\nBody.").redirect_from
      end

      def test_last_modified_at_falls_back_to_the_file_time
        with_site({"_posts/2021-02-03-x.md" => "Body."}) do
          File.utime(Time.utc(2001, 2, 3, 4, 5, 6), Time.utc(2001, 2, 3, 4, 5, 6), "_posts/2021-02-03-x.md")
          post = Post.load_all("_posts").first

          assert_equal Time.utc(2001, 2, 3, 4, 5, 6), post.last_modified_at
        end
      end

      def test_reading_time_rounds_up_to_whole_minutes
        {0 => 0, 1 => 1, 100 => 1, 101 => 2, 250 => 3}.each do |words, minutes|
          post = load_post("2021-02-03-x.md", ("word " * words).strip, words_per_minute: 100.0)

          assert_equal words, post.word_count
          assert_equal minutes, post.reading_time, "#{words} words at 100 wpm"
        end
      end

      def test_reading_time_defaults_to_180_words_per_minute
        assert_equal 1, load_post("2021-02-03-x.md", ("word " * 180).strip).reading_time
        assert_equal 2, load_post("2021-02-03-x.md", ("word " * 181).strip).reading_time
      end

      def test_reading_time_ignores_markup_and_scripts
        body = "<script>one two three</script>\n\n<!-- four five -->\n\nsix seven\n"

        assert_equal 2, load_post("2021-02-03-x.md", body).word_count
      end

      def test_load_all_reads_markdown_and_md_files_recursively_and_skips_others
        files = {
          "_posts/2021-01-01-b.md" => "B",
          "_posts/2021-01-02-a.markdown" => "A",
          "_posts/2021/2021-01-03-nested.md" => "N",
          "_posts/2021-01-04-ignored.txt" => "T",
          "_posts/2021-01-05-ignored.html" => "H"
        }

        with_site(files) do
          assert_equal %w[b a nested], Post.load_all("_posts").map(&:slug)
        end
      end

      def test_load_all_returns_no_posts_for_an_empty_directory
        with_site do
          assert_equal [], Post.load_all("_posts")
        end
      end

      def test_an_invalid_front_matter_date_raises_naming_the_file
        error = assert_raises(ArgumentError) { load_post("2021-02-03-x.md", "---\ndate: not a date\n---\nBody.") }

        assert_equal '_posts/2021-02-03-x.md: invalid date "not a date"', error.message
      end

      def test_an_impossible_filename_date_raises_naming_the_file
        error = assert_raises(ArgumentError) { load_post("2021-13-45-x.md", "Body.") }

        assert_equal '_posts/2021-13-45-x.md: invalid date "2021-13-45"', error.message
      end

      def test_an_invalid_last_modified_at_raises_naming_the_file
        error = assert_raises(ArgumentError) { load_post("2021-02-03-x.md", "---\nlast_modified_at: soon\n---\nBody.") }

        assert_equal '_posts/2021-02-03-x.md: invalid date "soon"', error.message
      end

      private

      def fixture_posts
        self.class.fixture_posts
      end

      def load_post(filename, content, **options)
        with_site({"_posts/#{filename}" => content}) do
          posts = Post.load_all("_posts", **options)
          assert_equal 1, posts.size
          posts.first
        end
      end
    end
  end
end
