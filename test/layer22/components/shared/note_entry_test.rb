# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class NoteEntryTest < TestCase
        def note(index)
          fixture_site.notes[index]
        end

        def render_entry(note)
          parse_html(NoteEntry.new(site: fixture_site, note:).call).at_css("article")
        end

        def test_is_an_h_entry
          entry = render_entry(note(0))

          assert_equal "article", entry.name
          assert_includes entry["class"].split, "h-entry"
          assert entry.at_css(".e-content")
        end

        def test_time_links_to_the_notes_page
          link = render_entry(note(0)).at_css("a.u-url")
          time = link.at_css("time.dt-published")

          assert_equal "/notes/2021/05/01/093000/", link["href"]
          assert_equal "2021-05-01T09:30:00+02:00", time["datetime"]
          assert_equal "May 1, 2021 · 09:30", time.text
        end

        def test_renders_the_body_as_html
          body = render_entry(note(0)).at_css(".e-content")

          assert_equal "A plain note with no link.", body.text.strip
          assert_equal "no", body.at_css("p em").text
        end

        def test_body_html_is_not_escaped
          entry = render_entry(note(0).with(body_html: "<p>Raw <strong>html</strong> &amp; more</p>"))

          assert_equal "html", entry.at_css(".e-content strong").text
          assert_equal "Raw html & more", entry.at_css(".e-content p").text
        end

        def test_a_note_without_a_link_has_only_its_permalink
          entry = render_entry(note(0))

          assert_equal 1, entry.css("a").size
          assert_empty entry.css("img, svg")
        end

        def test_renders_a_link_card_for_a_link
          entry = render_entry(note(1))

          assert_equal "https://www.example.org/wide", entry.css("a").last["href"]
          assert_includes entry.text, "A wide preview"
          assert_empty entry.css("[data-youtube-id]")
        end

        def test_renders_a_youtube_player_for_a_youtube_link
          entry = render_entry(note(3))

          assert_equal "dQw4w9WgXcQ", entry.at_css("a[data-youtube-id]")["data-youtube-id"]
          assert entry.at_css("svg")
          assert_includes entry.text, "Watch this."
          assert_includes entry.text, "A video"
        end

        def test_a_link_only_note_has_no_body
          entry = render_entry(note(4))
          content = entry.at_css(".e-content")

          assert_equal ["https://example.com/only-a-link"], content.css("a").map { |a| a["href"] }
          assert_equal %w[a], content.element_children.map(&:name)
        end

        def test_renders_no_script
          assert_empty render_entry(note(3)).css("script")
        end
      end
    end
  end
end
