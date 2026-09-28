# frozen_string_literal: true

require "test_helper"

module Layer22
  module Content
    class PageTest < TestCase
      def self.fixture_pages
        @fixture_pages ||= Dir.chdir(FIXTURE_ROOT) { Page.load_all("_pages") }.to_h { |page| [page.relative_path, page] }
      end

      def test_load_all_reads_the_fixture_pages_that_have_a_permalink
        assert_equal %w[/about /archive /categories /colophon /hidden /moved /notes/ /tags /til],
          fixture_pages.values.map(&:permalink)
      end

      def test_load_all_drops_pages_without_a_permalink
        refute_includes fixture_pages.keys, "_pages/no-permalink.md"
      end

      def test_about_reads_its_front_matter
        page = fixture_pages.fetch("_pages/about.md")

        assert_equal "About", page.title
        assert_equal "/about", page.permalink
        assert_equal "page", page.layout
        assert_equal "About the fixture.", page.description
        assert_nil page.redirect_to
        assert_equal "_pages/about.md", page.relative_path
      end

      def test_about_renders_its_markdown_body
        assert_equal %(<h1 id="about">About</h1>\n<p>Some words about the fixture.</p>\n), fixture_pages.fetch("_pages/about.md").body_html
      end

      def test_about_keeps_the_whole_front_matter
        expected = {"layout" => "page", "title" => "About", "permalink" => "/about", "description" => "About the fixture."}

        assert_equal expected, fixture_pages.fetch("_pages/about.md").front_matter
      end

      def test_layout_defaults_to_page
        assert_equal "page", fixture_pages.fetch("_pages/colophon.html").layout
        assert_equal "page", fixture_pages.fetch("_pages/hidden.md").layout
      end

      def test_layout_is_read_from_front_matter
        assert_equal "archive", fixture_pages.fetch("_pages/archive.md").layout
        assert_equal "notes", fixture_pages.fetch("_pages/notes.html").layout
      end

      def test_sitemap_defaults_to_true_and_can_be_switched_off
        assert_equal true, fixture_pages.fetch("_pages/about.md").sitemap
        assert_equal false, fixture_pages.fetch("_pages/hidden.md").sitemap
      end

      def test_redirect_to_is_read_from_front_matter
        page = fixture_pages.fetch("_pages/moved.md")

        assert_equal "https://elsewhere.test/landing", page.redirect_to
        assert_equal "", page.body_html
      end

      def test_listing_stays_available_in_the_front_matter
        assert_equal "categories", fixture_pages.fetch("_pages/categories.html").front_matter["listing"]
        assert_equal "tags", fixture_pages.fetch("_pages/tags.html").front_matter["listing"]
        assert_equal "tils", fixture_pages.fetch("_pages/til.html").front_matter["listing"]
      end

      def test_html_pages_keep_their_body_verbatim
        assert_equal %(\n<p class="raw">Hand-written HTML.</p>\n), fixture_pages.fetch("_pages/colophon.html").body_html
      end

      def test_html_pages_are_not_run_through_markdown
        body = %(<p>"straight" *not emphasised* -- and ...</p>\n)
        page = load_page("raw.html", "---\npermalink: /raw\n---\n#{body}")

        assert_equal body, page.body_html
      end

      def test_markdown_pages_are_rendered
        page = load_page("md.md", %(---\npermalink: /md\n---\n# Hi\n\n"quoted" *text*\n))

        assert_equal %(<h1 id="hi">Hi</h1>\n<p>“quoted” <em>text</em></p>\n), page.body_html
      end

      def test_title_decodes_entities_and_may_be_absent
        assert_equal "Q&A — notes", load_page("a.md", "---\npermalink: /a\ntitle: Q&amp;A &mdash; notes\n---\n").title
        assert_nil load_page("b.md", "---\npermalink: /b\n---\n").title
      end

      def test_description_may_be_absent
        assert_nil load_page("a.md", "---\npermalink: /a\n---\n").description
      end

      def test_pages_without_usable_front_matter_are_dropped
        files = {
          "_pages/none.md" => "No front matter at all.\n",
          "_pages/unterminated.md" => "---\npermalink: /unterminated\nnever closed\n",
          "_pages/empty.md" => "---\n---\nBody.\n",
          "_pages/kept.md" => "---\npermalink: /kept\n---\n"
        }

        with_site(files) do
          assert_equal ["/kept"], Page.load_all("_pages").map(&:permalink)
        end
      end

      def test_load_all_reads_md_markdown_and_html_recursively_and_skips_others
        files = {
          "_pages/a.md" => "---\npermalink: /a\n---\n",
          "_pages/b.markdown" => "---\npermalink: /b\n---\n",
          "_pages/c.html" => "---\npermalink: /c\n---\n",
          "_pages/sub/d.md" => "---\npermalink: /d\n---\n",
          "_pages/e.txt" => "---\npermalink: /e\n---\n"
        }

        with_site(files) do
          assert_equal %w[/a /b /c /d], Page.load_all("_pages").map(&:permalink)
        end
      end

      def test_last_modified_at_is_the_file_time_without_git_history
        with_site({"_pages/a.md" => "---\npermalink: /a\n---\n"}) do
          File.utime(Time.utc(2001, 2, 3, 4, 5, 6), Time.utc(2001, 2, 3, 4, 5, 6), "_pages/a.md")

          assert_equal Time.utc(2001, 2, 3, 4, 5, 6), Page.load_all("_pages").first.last_modified_at
        end
      end

      def test_invalid_front_matter_raises
        with_site({"_pages/bad.md" => "---\npermalink: [unclosed\n---\n"}) do
          assert_raises(Psych::SyntaxError) { Page.load_all("_pages") }
        end
      end

      private

      def fixture_pages
        self.class.fixture_pages
      end

      def load_page(filename, content)
        with_site({"_pages/#{filename}" => content}) do
          pages = Page.load_all("_pages")
          assert_equal 1, pages.size
          pages.first
        end
      end
    end
  end
end
