# frozen_string_literal: true

require "test_helper"

module Layer22
  module Rendering
    class CSSTest < TestCase
      def test_combined_css_reads_the_fixture_stylesheets_in_cascade_order
        css = in_fixture_site { CSS.combined_css }

        assert_equal "/* fixture normalize */\n\n/* fixture base */\n\n/* fixture components */\n", css
      end

      def test_combined_css_orders_normalize_then_base_then_components
        files = {"styles/normalize.css" => "N", "styles/base.css" => "B", "styles/components.css" => "C"}

        with_site(files) do
          assert_equal "N\nB\nC", CSS.combined_css
        end
      end

      def test_combined_css_leaves_out_the_syntax_stylesheet
        with_site({"styles/syntax.css" => "SYNTAX"}) do
          refute_includes CSS.combined_css, "SYNTAX"
        end
      end

      def test_combined_css_reads_the_files_as_they_are
        files = {"styles/normalize.css" => "a  {\n  b: c;\n}\n", "styles/base.css" => "", "styles/components.css" => "/* end */"}

        with_site(files) do
          assert_equal "a  {\n  b: c;\n}\n\n\n/* end */", CSS.combined_css
        end
      end

      def test_combined_css_raises_when_a_stylesheet_is_missing
        with_site do
          File.delete("styles/base.css")

          error = assert_raises(Errno::ENOENT) { CSS.combined_css }
          assert_includes error.message, "styles/base.css"
        end
      end

      def test_load_syntax_reads_the_syntax_stylesheet
        assert_equal "/* fixture syntax */\n", in_fixture_site { CSS.load_syntax }
      end

      def test_load_syntax_returns_the_file_as_it_is
        with_site({"styles/syntax.css" => ".k { color: red }\n\n"}) do
          assert_equal ".k { color: red }\n\n", CSS.load_syntax
        end
      end

      def test_load_syntax_raises_when_the_stylesheet_is_missing
        with_site do
          File.delete("styles/syntax.css")

          assert_raises(Errno::ENOENT) { CSS.load_syntax }
        end
      end
    end
  end
end
