# frozen_string_literal: true

require_relative "support"

module Layer22
  module NotesTest
    class CreateTest < ServerTestCase
      TIME = Time.new(2026, 9, 28, 10, 15, 30, "+02:00")
      PATH = "_notes/2026/09/2026-09-28-101530.md"
      YOUTUBE_ID = "dQw4w9WgXcQ"

      def test_writes_a_note_without_a_link
        with_site do
          path = Notes.create("Just a thought.", time: TIME)

          assert_equal PATH, path
          assert_equal "---\ndate: 2026-09-28 10:15:30 +0200\n---\n\nJust a thought.\n", File.read(path)
        end
      end

      def test_does_not_fetch_anything_without_a_link
        with_site do
          fetch = ->(_url, _basename) { flunk "should not fetch" }

          Notes.stub(:fetch_link, fetch) { Notes.create("Just a thought, see https://example.com/a for more.", time: TIME) }
        end
      end

      def test_pads_the_date_and_time_in_the_path
        with_site do
          path = Notes.create("Early.", time: Time.new(2026, 1, 5, 3, 4, 5, "+01:00"))

          assert_equal "_notes/2026/01/2026-01-05-030405.md", path
          assert_includes File.read(path), "date: 2026-01-05 03:04:05 +0100\n"
        end
      end

      def test_creates_the_directories_for_each_month
        with_site do
          Notes.create("One", time: TIME)
          Notes.create("Two", time: Time.new(2026, 10, 1, 8, 0, 0, "+02:00"))

          assert_equal %w[_notes/2026/09/2026-09-28-101530.md _notes/2026/10/2026-10-01-080000.md], Dir.glob("_notes/**/*.md").sort
        end
      end

      def test_keeps_the_body_as_written_apart_from_the_surrounding_whitespace
        with_site do
          path = Notes.create("\n\n  First paragraph.\n\nSecond, with *emphasis* and żółć.\n\n", time: TIME)

          assert_equal "---\ndate: 2026-09-28 10:15:30 +0200\n---\n\nFirst paragraph.\n\nSecond, with *emphasis* and żółć.\n", File.read(path)
        end
      end

      def test_links_bare_urls_in_the_body
        with_site do
          path = Notes.create("Compare https://a.example/x, and https://b.example/y. Not `https://c.example`.", time: TIME)

          assert_equal(
            "---\ndate: 2026-09-28 10:15:30 +0200\n---\n\nCompare <https://a.example/x>, and <https://b.example/y>. Not `https://c.example`.\n",
            File.read(path)
          )
        end
      end

      def test_writes_the_fetched_link_as_front_matter
        @server.serve("/post", page(<<~HTML))
          <meta property="og:title" content="A Post">
          <meta property="og:site_name" content="Example Blog">
          <meta property="og:description" content="What it is about.">
        HTML

        with_site do
          path = Notes.create("#{@server.url("/post")}\n\nMy comment.", time: TIME)

          assert_equal(
            <<~NOTE,
              ---
              date: 2026-09-28 10:15:30 +0200
              link:
                url: #{@server.url("/post")}
                site: Example Blog
                title: A Post
                description: What it is about.
              ---

              My comment.
            NOTE
            File.read(path)
          )
        end
      end

      def test_takes_a_trailing_url_as_the_link
        @server.serve("/post", page(%(<meta property="og:title" content="A Post">)))

        with_site do
          Notes.create("Worth a read #{@server.url("/post")}", time: TIME)

          note = load_note
          assert_equal "Worth a read", Nokogiri::HTML5.fragment(note.body_html).text.strip
          assert_equal @server.url("/post"), note.link.url
          assert_equal "A Post", note.link.title
        end
      end

      def test_a_note_that_is_only_a_link_has_an_empty_body
        @server.serve("/post", page(%(<meta property="og:title" content="A Post">)))

        with_site do
          path = Notes.create(@server.url("/post"), time: TIME)

          assert File.read(path).end_with?("---\n\n\n")
          note = load_note
          assert_equal "", note.body_html
          assert_equal "A Post", note.label
        end
      end

      def test_saves_the_thumbnail_named_after_the_note
        @server.serve("/post", page(%(<meta property="og:image" content="/cover.png">)))
        @server.serve("/cover.png", png(4, 2), type: "image/png")

        with_site do
          path = Notes.create("#{@server.url("/post")} Look at this", time: TIME)

          assert_equal png(4, 2), File.binread("images/notes/2026-09-28-101530.png")
          assert_includes File.read(path), "  image: \"/images/notes/2026-09-28-101530.png\"\n"
          link = load_note.link
          assert_equal "/images/notes/2026-09-28-101530.png", link.image
          assert_equal [4, 2], [link.image_width, link.image_height]
          assert link.wide_image?
        end
      end

      def test_records_the_video_id_of_a_youtube_link
        with_site do
          path = nil
          with_oembed { path = Notes.create("https://youtu.be/#{YOUTUBE_ID}\n\nGreat talk.", time: TIME) }

          content = File.read(path)
          assert_includes content, "link:\n  url: https://youtu.be/#{YOUTUBE_ID}\n  site: YouTube\n  youtube: #{YOUTUBE_ID}\n  title: Great Talk\n  author: A Speaker\n"
          refute_includes content, "image:"
          refute Dir.exist?("images")
          link = load_note.link
          assert_equal YOUTUBE_ID, link.youtube
          assert_equal "Great Talk", link.title
          assert_nil link.image
        end
      end

      def test_a_video_id_that_looks_like_a_number_stays_a_string
        with_site do
          with_oembed { Notes.create("https://youtu.be/12345678901", time: TIME) }

          assert_equal "12345678901", load_note.link.youtube
        end
      end

      def test_link_metadata_survives_yaml_for_awkward_values
        titles = [
          "Ruby: \"the\" #1 - Café ☕", "yes", "null", "123", "1.5", "2026-09-28", "- dash", "# hash", "key: value",
          "'quoted'", "\"double\"", "~", "  padded  ", "multi\nline", "[bracketed]", "{braced}", "@at", "%percent", "!bang", "&anchor", "*star", "|pipe", ">fold"
        ]

        with_site do
          titles.each_with_index do |title, index|
            time = TIME + index
            metadata = {"title" => title, "description" => "#{title}\n\nSecond: paragraph"}
            Notes.stub(:page_metadata, ->(_url) { metadata.dup }) { Notes.create("https://example.com/post\n\nNote #{index}", time:) }
          end

          notes = Content::Note.load_all("_notes")

          assert_equal titles.size, notes.size
          notes.zip(titles).each do |note, title|
            assert_equal title, note.link.title, title.inspect
            assert_equal "#{title}\n\nSecond: paragraph", note.link.description, title.inspect
          end
        end
      end

      def test_the_written_note_loads_with_its_date_and_link
        @server.serve("/post", page(<<~HTML))
          <meta property="og:title" content="A Post">
          <meta property="og:site_name" content="Example Blog">
          <meta property="og:description" content="What it is about.">
        HTML

        with_site do
          Notes.create("#{@server.url("/post")}\n\nMy *comment* on https://example.com/x.", time: TIME)

          note = load_note
          assert_equal TIME, note.date
          assert_equal "101530", note.slug
          assert_equal "/notes/2026/09/28/101530/", note.permalink
          assert_includes note.body_html, %(<a href="https://example.com/x">https://example.com/x</a>)
          assert_includes note.body_html, "<em>comment</em>"
          assert_equal "Example Blog", note.link.site
          assert_equal "What it is about.", note.link.description
          assert_nil note.link.youtube
          assert_nil note.link.image
        end
      end

      def test_a_failed_fetch_still_writes_the_note_with_the_bare_link
        with_site do
          path = nil
          stderr = nil
          with_refused_connections do
            _, stderr = capture_io { path = Notes.create("http://127.0.0.1:9/post\n\nMy comment.", time: TIME) }
          end

          link = load_note.link
          assert_equal "http://127.0.0.1:9/post", link.url
          assert_equal "127.0.0.1", link.site
          assert_nil link.title
          assert_nil link.image
          assert_equal 1, stderr.lines.size
          assert_match(/\ACould not fetch http:\/\/127\.0\.0\.1:9\/post: /, stderr)
          assert_includes File.read(path), "\n\nMy comment.\n"
        end
      end

      def test_empty_text_is_nothing_to_note
        with_site do
          ["", "   ", "\n\t\n"].each do |text|
            error = assert_raises(Notes::Error) { Notes.create(text, time: TIME) }

            assert_equal "Nothing to note", error.message
          end
          refute Dir.exist?("_notes")
        end
      end

      def test_refuses_to_overwrite_an_existing_note
        with_site({PATH => "existing"}) do
          error = assert_raises(Notes::Error) { Notes.create("Another thought.", time: TIME) }

          assert_equal "#{PATH} already exists", error.message
          assert_equal "existing", File.read(PATH)
        end
      end

      def test_refuses_before_fetching_anything_when_the_note_exists
        with_site({PATH => "existing"}) do
          assert_raises(Notes::Error) { Notes.create(@server.url("/post"), time: TIME) }

          assert_empty @server.requests
          refute Dir.exist?("images")
          assert_equal "existing", File.read(PATH)
        end
      end

      def test_a_second_note_in_the_next_second_does_not_clash
        with_site do
          first = Notes.create("One", time: TIME)
          second = Notes.create("Two", time: TIME + 1)

          assert_equal PATH, first
          assert_equal "_notes/2026/09/2026-09-28-101531.md", second
        end
      end

      private

      def page(head)
        "<!DOCTYPE html><html><head>#{head}</head><body></body></html>"
      end

      def load_note
        Content::Note.load_all("_notes").fetch(0)
      end

      def with_oembed(&)
        data = {"title" => "Great Talk", "author_name" => "A Speaker", "provider_name" => "YouTube"}
        fake = ->(url, **) { [JSON.generate(data).b, url, "application/json"] }
        Notes.stub(:get, fake, &)
      end
    end
  end
end
