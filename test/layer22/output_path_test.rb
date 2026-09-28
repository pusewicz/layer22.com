# frozen_string_literal: true

require "test_helper"

module Layer22
  class OutputPathTest < TestCase
    def test_root_url_is_the_index_file
      assert_equal "_site/index.html", OutputPath.for("/", output_dir: "_site")
    end

    def test_extensionless_url_gets_an_html_extension
      assert_equal "_site/about.html", OutputPath.for("/about", output_dir: "_site")
    end

    def test_nested_extensionless_url_gets_an_html_extension
      assert_equal "_site/a/b.html", OutputPath.for("/a/b", output_dir: "_site")
    end

    def test_trailing_slash_url_is_a_directory_index
      assert_equal "_site/2015/index.html", OutputPath.for("/2015/", output_dir: "_site")
      assert_equal "_site/til/2021/03/05/first-til/index.html",
        OutputPath.for("/til/2021/03/05/first-til/", output_dir: "_site")
    end

    def test_url_with_an_extension_is_kept_as_is
      assert_equal "_site/404.html", OutputPath.for("/404.html", output_dir: "_site")
      assert_equal "_site/notes/feed.xml", OutputPath.for("/notes/feed.xml", output_dir: "_site")
    end

    def test_a_dot_in_a_directory_name_is_not_an_extension
      assert_equal "_site/v1.2/release.html", OutputPath.for("/v1.2/release", output_dir: "_site")
    end

    def test_output_dir_can_be_absolute_or_have_a_trailing_slash
      assert_equal "/tmp/out/about.html", OutputPath.for("/about", output_dir: "/tmp/out")
      assert_equal "_site/about.html", OutputPath.for("/about", output_dir: "_site/")
    end

    def test_output_dir_is_required
      assert_raises(ArgumentError) { OutputPath.for("/about") }
    end
  end
end
