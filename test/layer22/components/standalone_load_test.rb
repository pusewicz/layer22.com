# frozen_string_literal: true

require "test_helper"
require "open3"
require "rbconfig"

module Layer22
  module Components
    # Components inheriting straight from Phlex::HTML must load the gem themselves:
    # they are not guaranteed to be preceded by Base, which does. Each runs in a
    # fresh Ruby, as the suite loads Base long before any of them.
    class StandaloneLoadTest < TestCase
      LIB = File.expand_path("../../../lib", __dir__)
      RESUME = {
        "basics" => {"name" => "Grace Hopper", "headline" => "Rear Admiral", "location" => "New York, USA",
                     "availability" => "Retired", "email" => "grace@example.test", "links" => []},
        "summary" => "Invented the first compiler.",
        "experience" => [],
        "open_source" => {"intro" => "Writing open source.", "projects" => []},
        "skills" => [],
        "languages" => "English"
      }.freeze

      def render_in_fresh_ruby(expression)
        script = %(require "layer22"; print #{expression}.call)
        Open3.capture3(RbConfig.ruby, "-I", LIB, "-e", script)
      end

      def assert_renders_standalone(expression, expected)
        stdout, stderr, status = render_in_fresh_ruby(expression)

        assert status.success?, "#{expression} failed to render on its own:\n#{stderr}"
        assert_includes stdout, expected
      end

      def test_redirect_page_renders_without_base_loaded
        assert_renders_standalone(%(Layer22::Components::Pages::RedirectPage.new(to: "https://elsewhere.test/")), "Redirecting…")
      end

      def test_resume_print_page_renders_without_base_loaded
        assert_renders_standalone("Layer22::Components::Pages::ResumePrintPage.new(resume: #{RESUME.inspect})", "Grace Hopper — Resume")
      end

      def test_youtube_script_renders_without_base_loaded
        assert_renders_standalone("Layer22::Components::Shared::YoutubeScript.new", "youtube-nocookie.com")
      end
    end
  end
end
