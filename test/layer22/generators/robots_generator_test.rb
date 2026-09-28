# frozen_string_literal: true

require "test_helper"

module Layer22
  module Generators
    class RobotsGeneratorTest < TestCase
      def test_generate_writes_robots_txt
        Dir.mktmpdir do |dir|
          out, = capture_io { RobotsGenerator.new(fixture_site).generate(output_dir: dir) }

          path = File.join(dir, "robots.txt")
          assert_equal "Generated #{path}\n", out
          assert_equal <<~ROBOTS, File.read(path)
            User-agent: *
            Disallow: /cdn-cgi/

            User-agent: *
            Allow: /

            Sitemap: https://example.test/sitemap.xml
          ROBOTS
        end
      end

      def test_sitemap_url_has_no_doubled_slash_when_the_site_url_ends_in_one
        with_site({}, config: {url: "https://example.test/"}) do
          Dir.mktmpdir do |dir|
            capture_io { RobotsGenerator.new(Site.new).generate(output_dir: dir) }

            assert_includes File.read(File.join(dir, "robots.txt")), "Sitemap: https://example.test/sitemap.xml\n"
          end
        end
      end

      def test_generate_overwrites_an_existing_file
        Dir.mktmpdir do |dir|
          write_file(File.join(dir, "robots.txt"), "stale")
          capture_io { RobotsGenerator.new(fixture_site).generate(output_dir: dir) }

          refute_includes File.read(File.join(dir, "robots.txt")), "stale"
        end
      end
    end
  end
end
