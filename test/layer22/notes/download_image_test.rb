# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class DownloadImageTest < ServerTestCase
      def test_saves_the_image_under_images_notes
        @server.serve("/cover", png, type: "image/png")

        with_site do
          path = Notes.download_image([@server.url("/cover")], "2026-09-28-101530")

          assert_equal "/images/notes/2026-09-28-101530.png", path
          assert_equal png, File.binread("images/notes/2026-09-28-101530.png")
        end
      end

      Notes::IMAGE_EXTENSIONS.each do |content_type, extension|
        define_method(:"test_saves_#{content_type.tr("/", "_")}_as_#{extension.delete(".")}") do
          @server.serve("/image", "image data", type: content_type)

          with_site do
            assert_equal "/images/notes/note#{extension}", Notes.download_image([@server.url("/image")], "note")
            assert_equal "image data", File.binread("images/notes/note#{extension}")
          end
        end
      end

      def test_ignores_content_type_parameters
        @server.serve("/cover", png, type: "image/png; charset=binary")

        with_site do
          assert_equal "/images/notes/note.png", Notes.download_image([@server.url("/cover")], "note")
        end
      end

      def test_saves_the_exact_bytes_even_when_the_server_labels_the_image_with_a_charset
        Notes::IMAGE_EXTENSIONS.each_key do |type|
          @server.serve("/#{type}", png, type: "#{type}; charset=utf-8")
        end

        with_site do
          Notes::IMAGE_EXTENSIONS.each do |type, extension|
            assert_equal "/images/notes/note#{extension}", Notes.download_image([@server.url("/#{type}")], "note"), type
            assert_equal png, File.binread("images/notes/note#{extension}"), type
          end
        end
      end

      def test_creates_the_directory_when_it_is_missing
        @server.serve("/cover", png, type: "image/png")

        with_site do
          refute Dir.exist?("images")

          Notes.download_image([@server.url("/cover")], "note")

          assert File.file?("images/notes/note.png")
        end
      end

      def test_follows_redirects_to_the_image
        @server.redirect("/short", "/real.png")
        @server.serve("/real.png", png, type: "image/png")

        with_site do
          assert_equal "/images/notes/note.png", Notes.download_image([@server.url("/short")], "note")
        end
      end

      def test_saves_an_image_of_exactly_the_size_limit
        @server.serve("/big", "\0".b * Notes::MAX_IMAGE_BYTES, type: "image/jpeg")

        with_site do
          assert_equal "/images/notes/note.jpg", Notes.download_image([@server.url("/big")], "note")
          assert_equal Notes::MAX_IMAGE_BYTES, File.size("images/notes/note.jpg")
        end
      end

      def test_skips_an_image_over_the_size_limit_and_warns
        @server.serve("/huge", "\0".b * (Notes::MAX_IMAGE_BYTES + 1), type: "image/jpeg")

        with_site do
          result = nil
          _, stderr = capture_io { result = Notes.download_image([@server.url("/huge")], "note") }

          assert_nil result
          assert_equal "Could not download a thumbnail:\n  #{@server.url("/huge")}: larger than 5242880 bytes\n", stderr
          refute Dir.exist?("images")
        end
      end

      def test_skips_an_unsupported_image_type_and_warns
        @server.serve("/logo.svg", "<svg/>", type: "image/svg+xml")

        with_site do
          result = nil
          _, stderr = capture_io { result = Notes.download_image([@server.url("/logo.svg")], "note") }

          assert_nil result
          assert_equal "Could not download a thumbnail:\n  #{@server.url("/logo.svg")}: image/svg+xml is not a supported image\n", stderr
          refute Dir.exist?("images")
        end
      end

      def test_skips_a_page_that_is_not_an_image
        @server.serve("/page", "<p>hi</p>", type: "text/html")

        with_site do
          result = nil
          _, stderr = capture_io { result = Notes.download_image([@server.url("/page")], "note") }

          assert_nil result
          assert_includes stderr, "  #{@server.url("/page")}: text/html is not a supported image\n"
        end
      end

      def test_skips_a_response_without_a_content_type
        @server.serve("/untyped", png, type: nil)

        with_site do
          result = nil
          _, stderr = capture_io { result = Notes.download_image([@server.url("/untyped")], "note") }

          assert_nil result
          assert_match(/^  #{Regexp.escape(@server.url("/untyped"))}: .*is not a supported image$/, stderr)
        end
      end

      def test_falls_through_to_the_next_candidate
        @server.serve("/missing-type", "x", type: "text/html")
        @server.serve("/second", png, type: "image/png")

        with_site do
          result = nil
          _, stderr = capture_io do
            result = Notes.download_image([@server.url("/nothing"), @server.url("/missing-type"), @server.url("/second")], "note")
          end

          assert_equal "/images/notes/note.png", result
          assert_empty stderr
          assert_equal png, File.binread("images/notes/note.png")
        end
      end

      def test_tries_candidates_in_order_and_stops_at_the_first_that_works
        @server.serve("/first", "first", type: "image/gif")
        @server.serve("/second", "second", type: "image/png")

        with_site do
          assert_equal "/images/notes/note.gif", Notes.download_image([@server.url("/first"), @server.url("/second")], "note")
        end
        assert_empty @server.requests_for("/second")
      end

      def test_lists_each_failure_in_one_warning
        @server.serve("/page", "x", type: "text/html")
        @server.serve("/broken", "x", type: "image/png", status: 500)

        with_site do
          result = nil
          urls = [@server.url("/nothing"), @server.url("/page"), @server.url("/broken")]
          _, stderr = capture_io { result = Notes.download_image(urls, "note") }

          assert_nil result
          assert_equal(
            <<~WARNING,
              Could not download a thumbnail:
                #{urls[0]}: 404 Not Found
                #{urls[1]}: text/html is not a supported image
                #{urls[2]}: 500 Internal Server Error
            WARNING
            stderr
          )
        end
      end

      def test_reports_a_refused_connection_as_a_failure
        with_site do
          result = nil
          stderr = nil
          with_refused_connections do
            _, stderr = capture_io { result = Notes.download_image(["http://127.0.0.1:9/cover.png"], "note") }
          end

          assert_nil result
          assert_equal 2, stderr.lines.size
          assert_match(%r{^  http://127\.0\.0\.1:9/cover\.png: Connection refused}, stderr)
        end
      end

      def test_reports_a_redirect_loop_as_a_failure
        @server.redirect("/loop", "/loop")

        with_site do
          _, stderr = capture_io { Notes.download_image([@server.url("/loop")], "note") }

          assert_includes stderr, "  #{@server.url("/loop")}: too many redirects\n"
        end
      end

      def test_does_not_write_anything_when_every_candidate_fails
        with_site do
          capture_io { Notes.download_image([@server.url("/nothing")], "note") }

          refute Dir.exist?("images")
        end
      end

      def test_names_the_file_after_the_basename
        @server.serve("/cover", png, type: "image/png")

        with_site do
          Notes.download_image([@server.url("/cover")], "2026-09-28-101530")
          Notes.download_image([@server.url("/cover")], "2026-09-28-101531")

          assert_equal %w[2026-09-28-101530.png 2026-09-28-101531.png], Dir.children("images/notes").sort
        end
      end
    end
  end
end
