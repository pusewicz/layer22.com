# frozen_string_literal: true

require "test_helper"
require_relative "../local_time_assertions"

module Layer22
  module Content
    class NoteTest < TestCase
      include LocalTimeAssertions

      def self.fixture_notes
        @fixture_notes ||= Dir.chdir(FIXTURE_ROOT) { Note.load_all("_notes") }.to_h { |note| [note.slug, note] }
      end

      def test_load_all_reads_the_fixture_notes_in_path_order
        assert_equal %w[093000 101500 121000 080000 200000 070000 090000 100000], fixture_notes.keys
      end

      def test_plain_note_is_untitled_and_takes_its_slug_from_the_time_in_the_filename
        note = fixture_notes.fetch("093000")

        assert_equal "", note.title
        assert_equal "093000", note.slug
        assert_equal "_notes/2021/05/2021-05-01-093000.md", note.relative_path
      end

      def test_plain_note_reads_its_date_tags_and_permalink
        note = fixture_notes.fetch("093000")

        assert_local_time "2021-05-01 09:30:00 +0200", note.date
        assert_equal %w[misc], note.tags
        assert_equal "/notes/2021/05/01/093000/", note.permalink
        assert_local_time "2021-05-01 09:30:00 +0200", note.last_modified_at
      end

      def test_plain_note_renders_its_body_without_a_trailing_newline
        note = fixture_notes.fetch("093000")

        assert_equal "<p>A plain note with <em>no</em> link.</p>", note.body_html
        assert_equal "A plain note with no link.", note.description
        assert_nil note.link
      end

      def test_wide_link_note_carries_its_link_and_thumbnail_size
        link = fixture_notes.fetch("101500").link

        assert_equal "https://www.example.org/wide", link.url
        assert_equal "Example Org", link.site
        assert_equal "A wide preview", link.title
        assert_equal "Someone", link.author
        assert_equal "Its description.", link.description
        assert_equal "/images/notes/wide.png", link.image
        assert_equal [200, 100], [link.image_width, link.image_height]
        assert_predicate link, :wide_image?
      end

      def test_square_link_note_has_a_thumbnail_that_is_not_wide
        link = fixture_notes.fetch("121000").link

        assert_equal [100, 100], [link.image_width, link.image_height]
        refute_predicate link, :wide_image?
        assert_nil link.site
      end

      def test_youtube_note_keeps_the_video_id_and_has_no_thumbnail
        link = fixture_notes.fetch("080000").link

        assert_equal "dQw4w9WgXcQ", link.youtube
        assert_nil link.image
        assert_nil link.image_width
      end

      def test_bluesky_note_keeps_the_post_and_its_thumbnail
        link = fixture_notes.fetch("090000").link

        assert_nil link.youtube
        assert_equal "ada.example.com", link.bluesky.handle
        assert_equal "Café ☕ notes at example.com #lisp\nSecond line", link.bluesky.text
        assert_equal "/images/notes/wide.png", link.image
        assert_predicate link, :wide_image?
      end

      def test_link_only_note_has_an_empty_body_and_no_description
        note = fixture_notes.fetch("200000")

        assert_equal "", note.body_html
        assert_nil note.description
        assert_equal "Only a link", note.link.title
      end

      def test_label_is_the_first_words_of_the_body
        assert_equal "A plain note with no link.", fixture_notes.fetch("093000").label
        assert_equal "Look at this.", fixture_notes.fetch("101500").label
      end

      def test_label_truncates_a_long_body_to_ten_words_with_an_ellipsis
        assert_equal "One two three four five six seven eight nine ten…", fixture_notes.fetch("070000").label
      end

      def test_label_falls_back_to_the_link_title_for_an_empty_body
        assert_equal "Only a link", fixture_notes.fetch("200000").label
      end

      def test_label_falls_back_to_the_first_words_of_a_bluesky_post_for_an_empty_body
        front_matter = <<~MD
          ---
          link:
            url: https://bsky.app/profile/ada.example.com/post/3kabc
            bluesky:
              handle: ada.example.com
              text: "\\nOne two three four five six seven eight nine ten eleven"
          ---
        MD

        assert_equal "One two three four five six seven eight nine ten…", load_note("2021-05-07-x.md", front_matter).label
      end

      def test_label_prefers_the_body_to_a_bluesky_post
        note = fixture_notes.fetch("090000")

        assert_equal "A post worth reading.", note.label
      end

      def test_label_falls_back_to_the_link_title_for_a_bluesky_post_without_text
        front_matter = <<~MD
          ---
          link:
            url: https://bsky.app/profile/ada.example.com/post/3kabc
            title: Ada's post
            bluesky:
              handle: ada.example.com
          ---
        MD

        assert_equal "Ada's post", load_note("2021-05-07-x.md", front_matter).label
      end

      def test_label_falls_back_to_the_first_words_of_an_instagram_caption_for_an_empty_body
        front_matter = <<~MD
          ---
          link:
            url: https://www.instagram.com/reel/a/
            instagram: reel
            description: One two three four five six seven eight nine ten eleven
          ---
        MD

        assert_equal "One two three four five six seven eight nine ten…", load_note("2021-05-07-x.md", front_matter).label
      end

      def test_label_falls_back_to_the_date_for_an_instagram_post_without_a_caption
        front_matter = "---\nlink:\n  url: https://www.instagram.com/reel/a/\n  instagram: reel\n---\n"

        assert_equal "Note from May 7, 2021", load_note("2021-05-07-x.md", front_matter).label
      end

      def test_label_prefers_the_body_to_an_instagram_caption
        assert_equal "Watch this reel.", fixture_notes.fetch("100000").label
      end

      def test_instagram_note_keeps_the_kind_and_caption
        link = fixture_notes.fetch("100000").link

        assert_equal "reel", link.instagram
        assert_equal "A short caption for the reel.", link.description
        assert_equal "/images/notes/square.png", link.image
      end

      def test_label_prefers_the_title
        note = load_note("2021-05-07-x.md", "---\ntitle: Fish &amp; chips\n---\nSome body text.")

        assert_equal "Fish & chips", note.title
        assert_equal "Fish & chips", note.label
      end

      def test_label_of_exactly_ten_words_has_no_ellipsis
        note = load_note("2021-05-07-x.md", "one two three four five six seven eight nine ten")

        assert_equal "one two three four five six seven eight nine ten", note.label
      end

      def test_label_of_eleven_words_is_cut_at_ten_with_an_ellipsis
        note = load_note("2021-05-07-x.md", "one two three four five six seven eight nine ten eleven")

        assert_equal "one two three four five six seven eight nine ten…", note.label
      end

      def test_label_reads_the_text_of_the_rendered_body
        note = load_note("2021-05-07-x.md", "**Bold** and [a link](https://example.test/) &amp; more\n\nSecond paragraph.")

        assert_equal "Bold and a link & more Second paragraph.", note.label
      end

      def test_label_falls_back_to_the_date_without_a_body_or_link_title
        assert_equal "Note from May 7, 2021", load_note("2021-05-07-x.md", "").label
        assert_equal "Note from Dec 25, 2021", load_note("2021-12-25-x.md", "").label
      end

      def test_label_falls_back_to_the_date_for_a_link_without_a_title
        note = load_note("2021-05-07-x.md", "---\nlink:\n  url: https://example.test/\n---\n")

        assert_equal "https://example.test/", note.link.url
        assert_equal "Note from May 7, 2021", note.label
      end

      def test_label_uses_the_local_date_of_a_utc_timestamp
        note = load_note("2021-12-31-x.md", "---\ndate: 2021-12-31 23:30:00 +0000\n---\n")

        assert_equal "Note from Jan 1, 2022", note.label
      end

      def test_date_comes_from_the_filename_without_front_matter
        note = load_note("2021-05-07-thing.md", "Body.")

        assert_local_time "2021-05-07 00:00:00 +0200", note.date
        assert_equal "thing", note.slug
        assert_equal "/notes/2021/05/07/thing/", note.permalink
      end

      def test_permalink_uses_the_local_date_of_a_utc_timestamp
        note = load_note("2021-05-01-x.md", "---\ndate: 2021-05-01 22:30:00 +0000\n---\nBody.")

        assert_local_time "2021-05-02 00:30:00 +0200", note.date
        assert_equal "/notes/2021/05/02/x/", note.permalink
      end

      def test_front_matter_date_overrides_the_filename_date
        note = load_note("2021-05-01-x.md", "---\ndate: 2022-01-02 03:04:05 +0100\n---\nBody.")

        assert_local_time "2022-01-02 03:04:05 +0100", note.date
        assert_equal "/notes/2022/01/02/x/", note.permalink
      end

      def test_filename_without_a_date_keeps_its_whole_name_as_the_slug
        note = load_note("scribble.md", "---\ndate: 2021-05-07 10:00:00 +0200\n---\nBody.")

        assert_equal "scribble", note.slug
        assert_equal "/notes/2021/05/07/scribble/", note.permalink
      end

      def test_a_note_without_any_date_falls_back_to_the_current_time
        note = load_note("scribble.md", "Body.")

        assert_in_delta Time.now.to_f, note.date.to_f, 5
        assert_equal "/notes/#{note.date.strftime("%Y/%m/%d")}/scribble/", note.permalink
      end

      def test_description_prefers_front_matter_over_the_excerpt
        assert_equal "Custom.", load_note("2021-05-07-x.md", "---\ndescription: Custom.\n---\nBody.").description
        assert_equal "Body.", load_note("2021-05-07-x.md", "Body.").description
      end

      def test_description_is_nil_for_an_empty_body
        assert_nil load_note("2021-05-07-x.md", "---\ntags: [a]\n---\n").description
      end

      def test_reads_singular_and_plural_tags
        assert_equal %w[one], load_note("2021-05-07-x.md", "---\ntag: one\n---\nBody.").tags
        assert_equal %w[a b], load_note("2021-05-07-x.md", "---\ntags: a b\n---\nBody.").tags
        assert_equal [], load_note("2021-05-07-x.md", "Body.").tags
      end

      def test_last_modified_at_prefers_front_matter_then_the_file_time
        explicit = load_note("2021-05-07-x.md", "---\nlast_modified_at: 2021-06-01 12:00:00 +0000\n---\nBody.")

        assert_local_time "2021-06-01 14:00:00 +0200", explicit.last_modified_at

        with_site({"_notes/2021-05-07-x.md" => "Body."}) do
          File.utime(Time.utc(2001, 2, 3, 4, 5, 6), Time.utc(2001, 2, 3, 4, 5, 6), "_notes/2021-05-07-x.md")

          assert_equal Time.utc(2001, 2, 3, 4, 5, 6), Note.load_all("_notes").first.last_modified_at
        end
      end

      def test_load_all_finds_notes_in_nested_directories_and_both_extensions
        files = {
          "_notes/2021/05/2021-05-01-a.md" => "A",
          "_notes/2021/05/2021-05-02-b.markdown" => "B",
          "_notes/2021-05-03-c.md" => "C",
          "_notes/2021-05-04-ignored.txt" => "D"
        }

        with_site(files) do
          assert_equal %w[a b c], Note.load_all("_notes").map(&:slug).sort
        end
      end

      def test_an_invalid_date_raises_naming_the_file
        error = assert_raises(ArgumentError) { load_note("2021-05-07-x.md", "---\ndate: someday\n---\nBody.") }

        assert_equal '_notes/2021-05-07-x.md: invalid date "someday"', error.message
      end

      def test_a_link_without_a_url_raises
        assert_raises(KeyError) { load_note("2021-05-07-x.md", "---\nlink:\n  title: No url\n---\nBody.") }
      end

      private

      def fixture_notes
        self.class.fixture_notes
      end

      def load_note(filename, content)
        with_site({"_notes/#{filename}" => content}) do
          notes = Note.load_all("_notes")
          assert_equal 1, notes.size
          notes.first
        end
      end
    end
  end
end
