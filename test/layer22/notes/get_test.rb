# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class GetTest < ServerTestCase
      def test_returns_the_body_final_url_and_content_type
        @server.serve("/page", "<p>Hello</p>", type: "text/html")

        body, url, content_type = Notes.get(@server.url("/page"))

        assert_equal "<p>Hello</p>", body
        assert_equal @server.url("/page"), url
        assert_equal "text/html", content_type
      end

      def test_content_type_has_no_parameters
        @server.serve("/page", "x", type: "text/html; charset=utf-8")

        assert_equal "text/html", Notes.get(@server.url("/page")).last
      end

      def test_returns_the_body_as_binary
        bytes = (0..255).map(&:chr).join.b
        @server.serve("/bytes", bytes, type: "application/octet-stream")

        body, = Notes.get(@server.url("/bytes"))

        assert_equal bytes, body
        assert_equal Encoding::BINARY, body.encoding
      end

      def test_tags_the_body_with_the_charset_the_server_declares
        {
          "UTF-8" => ["Café ☕", Encoding::UTF_8],
          "utf-8" => ["Café ☕", Encoding::UTF_8],
          "ISO-8859-1" => ["Café naïve", Encoding::ISO_8859_1],
          "windows-1252" => ["Café “quoted” €5", Encoding::Windows_1252]
        }.each do |charset, (text, encoding)|
          @server.serve("/#{charset}", text.encode(encoding), type: "text/html; charset=#{charset}")

          body, = Notes.get(@server.url("/#{charset}"))

          assert_equal encoding, body.encoding, charset
          assert body.valid_encoding?, charset
          assert_equal text, body.encode(Encoding::UTF_8), charset
        end
      end

      def test_decodes_every_kind_of_text_body
        %w[
          text/html text/plain text/xml application/xml application/xhtml+xml application/ld+json application/json image/svg+xml
        ].each do |type|
          @server.serve("/#{type}", "Café naïve".encode(Encoding::ISO_8859_1), type: "#{type}; charset=ISO-8859-1")

          body, = Notes.get(@server.url("/#{type}"))

          assert_equal Encoding::ISO_8859_1, body.encoding, type
          assert_equal "Café naïve", body.encode(Encoding::UTF_8), type
        end
      end

      def test_leaves_binary_bodies_alone_even_when_they_have_a_charset
        bytes = "\xFF\xD8\xFF\xE0Café".b
        %w[application/octet-stream image/png image/jpeg application/pdf font/woff2 video/mp4].each do |type|
          @server.serve("/#{type}", bytes, type: "#{type}; charset=utf-8")

          body, _, content_type = Notes.get(@server.url("/#{type}"))

          assert_equal bytes, body, type
          assert_equal Encoding::BINARY, body.encoding, type
          assert_equal type, content_type
        end
      end

      def test_does_not_mistake_a_type_that_only_ends_like_text_for_text
        bytes = "Café".b
        @server.serve("/type", bytes, type: "application/x-xml-not; charset=utf-8")

        assert_equal Encoding::BINARY, Notes.get(@server.url("/type")).first.encoding
      end

      def test_reads_a_quoted_charset
        @server.serve("/quoted", "Café ☕", type: %(text/html; charset="utf-8"))

        body, = Notes.get(@server.url("/quoted"))

        assert_equal Encoding::UTF_8, body.encoding
        assert_equal "Café ☕", body
      end

      def test_replaces_bytes_that_are_invalid_in_the_declared_charset
        @server.serve("/invalid", "Caf\xFF ☕".b, type: "text/html; charset=utf-8")

        body, = Notes.get(@server.url("/invalid"))

        assert body.valid_encoding?
        assert_equal Encoding::UTF_8, body.encoding
        assert_equal "Caf� ☕", body
      end

      def test_a_body_that_is_valid_in_the_declared_charset_is_not_scrubbed
        bytes = "Café ☕ �".b
        @server.serve("/valid", bytes, type: "text/html; charset=utf-8")

        assert_equal bytes, Notes.get(@server.url("/valid")).first.b
      end

      def test_tagging_the_body_does_not_change_its_bytes
        bytes = "Café naïve".encode(Encoding::ISO_8859_1).b
        @server.serve("/latin1", bytes, type: "text/html; charset=ISO-8859-1")

        assert_equal bytes, Notes.get(@server.url("/latin1")).first.b
      end

      def test_a_tagged_body_can_be_modified
        @server.serve("/utf8", "Café", type: "text/html; charset=utf-8")

        body, = Notes.get(@server.url("/utf8"))

        refute body.frozen?
        assert_equal Encoding::UTF_8, body.force_encoding(Encoding::UTF_8).encoding
      end

      def test_leaves_the_body_alone_when_the_charset_is_unknown
        bytes = "Café ☕".b
        @server.serve("/unknown", bytes, type: "text/html; charset=x-no-such-charset")

        body, url, content_type = Notes.get(@server.url("/unknown"))

        assert_equal bytes, body
        assert_equal Encoding::BINARY, body.encoding
        assert_equal @server.url("/unknown"), url
        assert_equal "text/html", content_type
      end

      def test_leaves_the_body_alone_when_no_charset_is_declared
        bytes = "Café ☕".b
        @server.serve("/untagged", bytes, type: "text/html")

        body, = Notes.get(@server.url("/untagged"))

        assert_equal bytes, body
        assert_equal Encoding::BINARY, body.encoding
      end

      def test_leaves_an_image_alone
        @server.serve("/cover.png", png, type: "image/png")

        body, _, content_type = Notes.get(@server.url("/cover.png"))

        assert_equal png, body
        assert_equal Encoding::BINARY, body.encoding
        assert_equal "image/png", content_type
      end

      def test_decodes_a_gzipped_body
        @server.serve("/zip", Zlib.gzip("zipped page"), type: "text/plain", headers: {"content-encoding" => "gzip"})

        assert_equal "zipped page", Notes.get(@server.url("/zip")).first
      end

      def test_sends_the_query_string
        @server.serve("/search", "found")

        Notes.get(@server.url("/search?q=a+b&page=2"))

        assert_equal ["q=a+b&page=2"], @server.requests_for("/search").map(&:query)
      end

      def test_identifies_itself_with_a_user_agent_and_language
        @server.serve("/page", "x")

        Notes.get(@server.url("/page"))

        headers = @server.requests_for("/page").first.headers
        assert_equal Notes::USER_AGENT, headers["user_agent"]
        assert_equal "en", headers["accept_language"]
      end

      def test_follows_a_redirect_to_an_absolute_url
        @server.redirect("/old", @server.url("/new"))
        @server.serve("/new", "arrived", type: "text/plain")

        body, url, content_type = Notes.get(@server.url("/old"))

        assert_equal "arrived", body
        assert_equal @server.url("/new"), url
        assert_equal "text/plain", content_type
      end

      def test_follows_a_redirect_to_an_absolute_path
        @server.redirect("/old/page", "/new/page")
        @server.serve("/new/page", "arrived")

        assert_equal @server.url("/new/page"), Notes.get(@server.url("/old/page"))[1]
      end

      def test_follows_a_redirect_to_a_relative_path
        @server.redirect("/dir/old", "new")
        @server.serve("/dir/new", "arrived")

        assert_equal @server.url("/dir/new"), Notes.get(@server.url("/dir/old"))[1]
      end

      def test_follows_a_redirect_to_a_parent_path
        @server.redirect("/dir/sub/old", "../new")
        @server.serve("/dir/new", "arrived")

        assert_equal @server.url("/dir/new"), Notes.get(@server.url("/dir/sub/old"))[1]
      end

      def test_follows_a_redirect_that_keeps_the_query
        @server.redirect("/old", "/new?a=1&b=2")
        @server.serve("/new", "arrived")

        Notes.get(@server.url("/old"))

        assert_equal ["a=1&b=2"], @server.requests_for("/new").map(&:query)
      end

      def test_follows_every_kind_of_redirect
        [301, 302, 303, 307, 308].each do |status|
          @server.redirect("/from-#{status}", "/to", status:)
        end
        @server.serve("/to", "arrived")

        [301, 302, 303, 307, 308].each do |status|
          assert_equal "arrived", Notes.get(@server.url("/from-#{status}")).first, status.to_s
        end
      end

      def test_follows_a_chain_of_redirects_and_reports_the_last_url
        @server.redirect("/a", "/b")
        @server.redirect("/b", "/c")
        @server.serve("/c", "end", type: "text/plain")

        body, url, = Notes.get(@server.url("/a"))

        assert_equal "end", body
        assert_equal @server.url("/c"), url
        assert_equal %w[/a /b /c], @server.requests.map(&:path)
      end

      def test_sends_the_same_headers_on_every_hop
        @server.redirect("/a", "/b")
        @server.serve("/b", "end")

        Notes.get(@server.url("/a"))

        assert_equal [Notes::USER_AGENT] * 2, @server.requests.map { |request| request.headers["user_agent"] }
      end

      def test_follows_five_redirects
        5.times { |index| @server.redirect("/hop#{index}", "/hop#{index + 1}") }
        @server.serve("/hop5", "made it")

        assert_equal "made it", Notes.get(@server.url("/hop0")).first
      end

      def test_gives_up_after_more_than_five_redirects
        6.times { |index| @server.redirect("/hop#{index}", "/hop#{index + 1}") }
        @server.serve("/hop6", "too far")

        error = assert_raises(RuntimeError) { Notes.get(@server.url("/hop0")) }

        assert_equal "too many redirects", error.message
        assert_equal (0..5).map { |index| "/hop#{index}" }, @server.requests.map(&:path).first(6)
        assert_empty @server.requests_for("/hop6")
      end

      def test_gives_up_on_a_redirect_loop
        @server.redirect("/loop", "/loop")

        error = assert_raises(RuntimeError) { Notes.get(@server.url("/loop")) }

        assert_equal "too many redirects", error.message
        assert_equal 6, @server.requests_for("/loop").size
      end

      def test_the_redirect_limit_can_be_set
        @server.redirect("/a", "/b")
        @server.redirect("/b", "/c")
        @server.serve("/c", "end")

        assert_equal "end", Notes.get(@server.url("/a"), redirects: 2).first
        assert_equal "too many redirects", assert_raises(RuntimeError) { Notes.get(@server.url("/a"), redirects: 1) }.message
        assert_equal "too many redirects", assert_raises(RuntimeError) { Notes.get(@server.url("/a"), redirects: 0) }.message
      end

      def test_a_missing_page_raises_with_the_status
        error = assert_raises(RuntimeError) { Notes.get(@server.url("/nothing")) }

        assert_equal "404 Not Found", error.message
      end

      def test_a_server_error_raises_with_the_status
        @server.serve("/broken", "oops", status: 500)

        error = assert_raises(RuntimeError) { Notes.get(@server.url("/broken")) }

        assert_equal "500 Internal Server Error", error.message
      end

      def test_a_missing_page_after_a_redirect_raises
        @server.redirect("/old", "/gone")

        error = assert_raises(RuntimeError) { Notes.get(@server.url("/old")) }

        assert_equal "404 Not Found", error.message
      end

      def test_an_unreachable_server_raises
        with_refused_connections do
          assert_raises(Errno::ECONNREFUSED) { Notes.get(@server.url("/page")) }
        end
      end

      def test_a_url_that_does_not_parse_raises
        assert_raises(URI::InvalidURIError) { Notes.get("http://[::1") }
      end
    end
  end
end
