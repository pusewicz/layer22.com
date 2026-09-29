# frozen_string_literal: true

require "test_helper"

module Layer22
  module Generators
    # Runs the generator against a fake cwebp that logs each call and writes
    # "webp:<source>" to its destination.
    class WebpGeneratorTest < TestCase
      Call = Data.define(:quality, :source, :destination)

      # What one run of the generator did: the scratch site's directory, what it
      # printed to stdout and stderr, and the calls it made to cwebp.
      Run = Data.define(:dir, :out, :err, :calls) do
        def output_path(relative)
          File.join(dir, "_site", relative)
        end

        def sources
          calls.map(&:source)
        end
      end

      def test_converts_jpg_jpeg_png_and_tiff_in_any_case
        images = %w[a.jpg b.jpeg c.png d.tiff E.PNG F.JPG G.Tiff H.JPEG]

        run_webp(images.to_h { |name| ["images/#{name}", "pixels"] }) do |run|
          assert_equal images.map { |name| "images/#{name}" }.sort, run.sources.sort
          images.each do |name|
            assert_equal "webp:images/#{name}\n", File.read(run.output_path("images/#{File.basename(name, ".*")}.webp")), name
          end
        end
      end

      def test_ignores_other_file_types
        run_webp(%w[a.gif b.txt c.webp d.svg e.png.bak f].to_h { |name| ["images/#{name}", "data"] }) do |run|
          assert_empty run.calls
          assert_empty run.out
          assert_empty run.err
        end
      end

      def test_preserves_subdirectories
        run_webp({"images/articles/2021/photo.png" => "pixels", "images/top.jpg" => "pixels"}) do |run|
          assert_equal "webp:images/articles/2021/photo.png\n", File.read(run.output_path("images/articles/2021/photo.webp"))
          assert_path_exists run.output_path("images/top.webp")
        end
      end

      def test_reports_each_conversion
        run_webp({"images/logo.png" => "pixels"}) do |run|
          assert_equal "WebP: images/logo.png → #{run.output_path("images/logo.webp")}\n", run.out
        end
      end

      def test_passes_the_configured_quality_to_cwebp
        run_webp({"images/a.png" => "pixels"}, config: {webp: {"quality" => 55, "img_dirs" => ["images"]}}) do |run|
          assert_equal [["55", "images/a.png"]], run.calls.map { |call| [call.quality, call.source] }
        end
      end

      def test_quality_defaults_to_75
        run_webp({"images/a.png" => "pixels"}, config: {webp: {"img_dirs" => ["images"]}}) do |run|
          assert_equal ["75"], run.calls.map(&:quality)
        end
      end

      def test_fixture_quality_is_used_when_the_config_is_unchanged
        run_webp({"images/a.png" => "pixels"}) do |run|
          assert_equal ["80"], run.calls.map(&:quality)
        end
      end

      def test_img_dirs_default_to_images
        run_webp({"images/a.png" => "pixels", "other/b.png" => "pixels"}, config: {webp: {}}) do |run|
          assert_equal ["images/a.png"], run.sources
        end
      end

      def test_only_configured_directories_are_converted
        files = {"images/a.png" => "pixels", "photos/b.png" => "pixels", "photos/nested/c.png" => "pixels"}

        run_webp(files, config: {webp: {"img_dirs" => ["photos"]}}) do |run|
          assert_equal %w[photos/b.png photos/nested/c.png], run.sources
          assert_path_exists run.output_path("photos/nested/c.webp")
          refute_path_exists run.output_path("images")
        end
      end

      def test_a_leading_slash_in_img_dirs_is_ignored
        run_webp({"images/a.png" => "pixels"}, config: {webp: {"img_dirs" => ["/images"]}}) do |run|
          assert_path_exists run.output_path("images/a.webp")
        end
      end

      def test_skips_images_that_already_have_a_webp_file
        files = {"images/old.png" => "pixels", "images/new.png" => "pixels", "_site/images/old.webp" => "existing"}

        run_webp(files) do |run|
          assert_equal ["images/new.png"], run.sources
          assert_equal "existing", File.read(run.output_path("images/old.webp"))
          refute_includes run.out, "old.png"
        end
      end

      def test_a_failing_conversion_warns_and_continues_with_the_next_image
        files = %w[a-broken.png b-fine.png c-broken.jpg d-fine.jpg].to_h { |name| ["images/#{name}", "pixels"] }

        run_webp(files) do |run|
          assert_equal %w[images/a-broken.png images/b-fine.png images/c-broken.jpg images/d-fine.jpg], run.sources
          assert_equal "WebP: cwebp could not convert images/a-broken.png\nWebP: cwebp could not convert images/c-broken.jpg\n", run.err
          assert_equal 2, run.out.lines.size
          assert_path_exists run.output_path("images/b-fine.webp")
          assert_path_exists run.output_path("images/d-fine.webp")
          refute_path_exists run.output_path("images/a-broken.webp")
        end
      end

      def test_overlapping_directories_do_not_convert_a_file_twice
        files = {"images/a.png" => "pixels", "images/sub/b.png" => "pixels", "images/sub/deeper/c.png" => "pixels"}

        run_webp(files, config: {webp: {"img_dirs" => ["images", "images/sub"]}}) do |run|
          assert_equal %w[images/a.png images/sub/b.png images/sub/deeper/c.png], run.sources
          assert_equal 3, run.out.lines.size
          assert_path_exists run.output_path("images/sub/deeper/c.webp")
        end
      end

      def test_a_missing_directory_among_the_configured_ones_is_skipped
        run_webp({"images/a.png" => "pixels"}, config: {webp: {"img_dirs" => ["missing", "images"]}}) do |run|
          assert_equal ["images/a.png"], run.sources
          assert_empty run.err
        end
      end

      def test_warns_once_and_stops_when_cwebp_is_not_installed
        files = %w[a.png b.png c.jpg].to_h { |name| ["images/#{name}", "pixels"] }

        run_webp(files, executables: {}) do |run|
          assert_equal "WebP: cwebp not found, skipping WebP conversion\n", run.err
          assert_empty run.out
          assert_empty Dir.glob(run.output_path("**/*.webp"))
        end
      end

      def test_no_images_directory_is_not_an_error_even_without_cwebp
        run_webp({}, executables: {}) do |run|
          assert_empty run.out
          assert_empty run.err
          refute_path_exists run.output_path("")
        end
      end

      def test_an_images_directory_without_convertible_images_does_not_need_cwebp
        run_webp({"images/only.gif" => "pixels"}, executables: {}) do |run|
          assert_empty run.out
          assert_empty run.err
        end
      end

      private

      # Builds a scratch site holding +files+, runs the generator into its
      # _site with only +executables+ (by default the fake cwebp) on the PATH,
      # and yields the Run while the site still exists.
      def run_webp(files, config: {}, executables: nil)
        with_site(files, config:) do |dir|
          log = File.join(dir, "cwebp.log")
          site = Site.new
          out, err = with_path(executables || {"cwebp" => fake_cwebp(log)}) do
            capture_io { WebpGenerator.new(site).generate(output_dir: File.join(dir, "_site")) }
          end
          yield Run.new(dir:, out:, err:, calls: read_calls(log))
        end
      end

      def read_calls(log)
        return [] unless File.exist?(log)

        File.readlines(log, chomp: true).map { |line| Call.new(*line.split(" ", 3)) }
      end

      def fake_cwebp(log)
        <<~SH
          while [ $# -gt 0 ]; do
            case "$1" in
              -quiet) ;;
              -q) quality=$2; shift ;;
              -o) destination=$2; shift ;;
              *) source=$1 ;;
            esac
            shift
          done
          echo "$quality $source $destination" >> "#{log}"
          case "$source" in
            *broken*) exit 1 ;;
          esac
          echo "webp:$source" > "$destination"
        SH
      end
    end
  end
end
