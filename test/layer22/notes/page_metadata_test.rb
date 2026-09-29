# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class PageMetadataTest < ServerTestCase
      def test_reads_open_graph_metadata
        page "/post", <<~HTML
          <title>Fallback title</title>
          <meta property="og:title" content="Open Graph title">
          <meta property="og:site_name" content="Example Blog">
          <meta property="og:description" content="A short summary.">
          <meta property="og:image" content="https://cdn.example.com/cover.png">
        HTML

        assert_equal(
          {
            "title" => "Open Graph title",
            "site" => "Example Blog",
            "description" => "A short summary.",
            "image_urls" => ["https://cdn.example.com/cover.png"]
          },
          Notes.page_metadata(@server.url("/post"))
        )
      end

      def test_title_prefers_open_graph_over_twitter_over_the_title_tag
        page "/all", <<~HTML
          <title>Title tag</title>
          <meta name="twitter:title" content="Twitter title">
          <meta property="og:title" content="Open Graph title">
        HTML
        page "/twitter", <<~HTML
          <title>Title tag</title>
          <meta name="twitter:title" content="Twitter title">
        HTML
        page "/tag", "<title>Title tag</title>"

        assert_equal "Open Graph title", Notes.page_metadata(@server.url("/all"))["title"]
        assert_equal "Twitter title", Notes.page_metadata(@server.url("/twitter"))["title"]
        assert_equal "Title tag", Notes.page_metadata(@server.url("/tag"))["title"]
      end

      def test_reads_meta_tags_by_name_or_by_property
        page "/mixed", <<~HTML
          <meta name="og:title" content="Named">
          <meta property="og:site_name" content="Property">
          <meta property="twitter:image" content="https://cdn.example.com/t.png">
        HTML

        metadata = Notes.page_metadata(@server.url("/mixed"))

        assert_equal "Named", metadata["title"]
        assert_equal "Property", metadata["site"]
        assert_equal ["https://cdn.example.com/t.png"], metadata["image_urls"]
      end

      def test_skips_blank_meta_tags_and_falls_back
        page "/blank", <<~HTML
          <title>Title tag</title>
          <meta property="og:title" content="   ">
          <meta name="twitter:title" content="">
          <meta property="og:description" content="">
          <meta name="description" content="Plain description">
        HTML

        metadata = Notes.page_metadata(@server.url("/blank"))

        assert_equal "Title tag", metadata["title"]
        assert_equal "Plain description", metadata["description"]
      end

      def test_skips_a_meta_tag_without_content
        page "/no-content", <<~HTML
          <meta property="og:title">
          <meta name="twitter:title" content="Twitter title">
        HTML

        assert_equal "Twitter title", Notes.page_metadata(@server.url("/no-content"))["title"]
      end

      def test_strips_whitespace_around_values
        page "/spaces", <<~HTML
          <title>
             Spaced title
          </title>
          <meta property="og:site_name" content="  Spaced site ">
        HTML

        metadata = Notes.page_metadata(@server.url("/spaces"))

        assert_equal "Spaced title", metadata["title"]
        assert_equal "Spaced site", metadata["site"]
      end

      def test_decodes_html_entities
        page "/entities", <<~HTML
          <title>Fish &amp; chips &mdash; &quot;great&quot;</title>
          <meta property="og:description" content="Salt &lt; pepper">
        HTML

        metadata = Notes.page_metadata(@server.url("/entities"))

        assert_equal %(Fish & chips — "great"), metadata["title"]
        assert_equal "Salt < pepper", metadata["description"]
      end

      def test_reads_utf_8_when_only_the_page_declares_its_charset
        @server.serve("/utf8", "<meta charset=\"utf-8\"><title>Café ☕</title>", type: "text/html")

        assert_equal "Café ☕", Notes.page_metadata(@server.url("/utf8"))["title"]
      end

      def test_reads_utf_8_when_only_the_header_declares_its_charset
        @server.serve("/utf8", <<~HTML, type: "text/html; charset=utf-8")
          <title>Café ☕ — “quoted”</title>
          <meta property="og:site_name" content="Zażółć">
          <meta property="og:description" content="Gęślą jaźń">
        HTML

        metadata = Notes.page_metadata(@server.url("/utf8"))

        assert_equal "Café ☕ — “quoted”", metadata["title"]
        assert_equal "Zażółć", metadata["site"]
        assert_equal "Gęślą jaźń", metadata["description"]
        assert_equal Encoding::UTF_8, metadata["title"].encoding
      end

      def test_reads_a_quoted_charset_declared_in_the_header
        @server.serve("/quoted", "<title>Café ☕</title>", type: %(text/html; charset="utf-8"))

        assert_equal "Café ☕", Notes.page_metadata(@server.url("/quoted"))["title"]
      end

      def test_replaces_bytes_that_are_invalid_in_the_declared_charset
        @server.serve("/invalid", <<~HTML.b, type: "text/html; charset=utf-8")
          <title>Caf\xFF</title>
          <meta property="og:site_name" content="Example \xC3">
          <meta property="og:description" content="Fine text">
        HTML

        metadata = Notes.page_metadata(@server.url("/invalid"))

        assert_equal "Caf�", metadata["title"]
        assert_equal "Example �", metadata["site"]
        assert_equal "Fine text", metadata["description"]
      end

      def test_reads_a_legacy_charset_declared_in_the_header
        {
          "ISO-8859-1" => "Café naïve résumé",
          "windows-1252" => "Café “quoted” €5"
        }.each do |charset, title|
          @server.serve("/#{charset}", "<title>#{title}</title>".encode(charset), type: "text/html; charset=#{charset}")

          result = Notes.page_metadata(@server.url("/#{charset}"))["title"]

          assert_equal title, result, charset
          assert_equal Encoding::UTF_8, result.encoding, charset
        end
      end

      def test_reads_the_meta_charset_when_the_header_charset_is_unknown
        @server.serve("/unknown", "<meta charset=\"utf-8\"><title>Café ☕</title>", type: "text/html; charset=x-no-such-charset")

        assert_equal "Café ☕", Notes.page_metadata(@server.url("/unknown"))["title"]
      end

      def test_reads_an_ascii_page_when_the_header_charset_is_unknown
        @server.serve("/unknown", "<title>Plain</title>", type: "text/html; charset=x-no-such-charset")

        assert_equal "Plain", Notes.page_metadata(@server.url("/unknown"))["title"]
      end

      def test_description_prefers_open_graph_over_twitter_over_the_plain_one
        page "/all", <<~HTML
          <meta name="description" content="Plain">
          <meta name="twitter:description" content="Twitter">
          <meta property="og:description" content="Open Graph">
        HTML
        page "/twitter", <<~HTML
          <meta name="description" content="Plain">
          <meta name="twitter:description" content="Twitter">
        HTML
        page "/plain", %(<meta name="description" content="Plain">)

        assert_equal "Open Graph", Notes.page_metadata(@server.url("/all"))["description"]
        assert_equal "Twitter", Notes.page_metadata(@server.url("/twitter"))["description"]
        assert_equal "Plain", Notes.page_metadata(@server.url("/plain"))["description"]
      end

      def test_a_description_of_the_limit_is_kept_whole
        description = (["abcd"] * 39 + ["abcde"]).join(" ")
        page "/exact", %(<meta property="og:description" content="#{description}">)

        assert_equal Notes::DESCRIPTION_LENGTH, description.length
        assert_equal description, Notes.page_metadata(@server.url("/exact"))["description"]
      end

      def test_a_description_over_the_limit_is_shortened_between_words
        description = (["abcd"] * 39 + ["abcdef"]).join(" ")
        page "/long", %(<meta property="og:description" content="#{description}">)

        shortened = Notes.page_metadata(@server.url("/long"))["description"]

        assert_equal Notes::DESCRIPTION_LENGTH + 1, description.length
        assert_operator shortened.length, :<=, Notes::DESCRIPTION_LENGTH
        assert_equal ["abcd"], shortened.chomp("…").split.uniq
        assert shortened.end_with?("…")
      end

      def test_image_prefers_secure_url_over_open_graph_over_twitter
        page "/all", <<~HTML
          <meta name="twitter:image" content="https://cdn.example.com/twitter.png">
          <meta property="og:image" content="https://cdn.example.com/og.png">
          <meta property="og:image:secure_url" content="https://cdn.example.com/secure.png">
        HTML
        page "/og", <<~HTML
          <meta name="twitter:image" content="https://cdn.example.com/twitter.png">
          <meta property="og:image" content="https://cdn.example.com/og.png">
        HTML
        page "/twitter", %(<meta name="twitter:image" content="https://cdn.example.com/twitter.png">)

        assert_equal ["https://cdn.example.com/secure.png"], Notes.page_metadata(@server.url("/all"))["image_urls"]
        assert_equal ["https://cdn.example.com/og.png"], Notes.page_metadata(@server.url("/og"))["image_urls"]
        assert_equal ["https://cdn.example.com/twitter.png"], Notes.page_metadata(@server.url("/twitter"))["image_urls"]
      end

      def test_resolves_a_root_relative_image_against_the_page
        page "/articles/post", %(<meta property="og:image" content="/img/cover.png">)

        assert_equal [@server.url("/img/cover.png")], Notes.page_metadata(@server.url("/articles/post"))["image_urls"]
      end

      def test_resolves_a_relative_image_against_the_page_directory
        page "/articles/post", %(<meta property="og:image" content="cover.png">)

        assert_equal [@server.url("/articles/cover.png")], Notes.page_metadata(@server.url("/articles/post"))["image_urls"]
      end

      def test_resolves_a_protocol_relative_image_with_the_pages_scheme
        page "/post", %(<meta property="og:image" content="//cdn.example.com/cover.png">)

        assert_equal ["http://cdn.example.com/cover.png"], Notes.page_metadata(@server.url("/post"))["image_urls"]
      end

      def test_resolves_a_relative_image_against_the_final_url_after_redirects
        @server.redirect("/short", "/articles/2026/post")
        page "/articles/2026/post", %(<meta property="og:image" content="cover.png">)

        assert_equal [@server.url("/articles/2026/cover.png")], Notes.page_metadata(@server.url("/short"))["image_urls"]
      end

      def test_resolves_a_relative_image_against_the_final_host_after_a_redirect_from_another_host
        other = LocalServer.new.start
        other.redirect("/short", @server.url("/articles/post"))
        page "/articles/post", %(<meta property="og:image" content="/cover.png">)

        assert_equal [@server.url("/cover.png")], Notes.page_metadata(other.url("/short"))["image_urls"]
      ensure
        other&.stop
      end

      def test_a_page_without_metadata_has_only_empty_values
        page "/bare", "<p>Nothing here</p>"

        assert_equal(
          {"title" => nil, "site" => nil, "description" => nil, "image_urls" => []},
          Notes.page_metadata(@server.url("/bare"))
        )
      end

      def test_accepts_xhtml
        @server.serve("/xhtml", "<html><head><title>XHTML</title></head></html>", type: "application/xhtml+xml")

        assert_equal "XHTML", Notes.page_metadata(@server.url("/xhtml"))["title"]
      end

      def test_a_page_that_is_not_html_raises
        @server.serve("/data", %({"title":"not a page"}), type: "application/json")

        error = assert_raises(RuntimeError) { Notes.page_metadata(@server.url("/data")) }

        assert_equal "not an HTML page (application/json)", error.message
      end

      def test_a_page_without_a_content_type_raises
        @server.serve("/untyped", "<title>x</title>", type: nil)

        error = assert_raises(RuntimeError) { Notes.page_metadata(@server.url("/untyped")) }

        assert_equal "not an HTML page ()", error.message
      end

      def test_a_missing_page_raises
        error = assert_raises(RuntimeError) { Notes.page_metadata(@server.url("/nothing")) }

        assert_equal "404 Not Found", error.message
      end

      private

      def page(path, head)
        @server.serve(path, "<!DOCTYPE html><html><head>#{head}</head><body></body></html>")
      end
    end
  end
end
