# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  module Components
    module Pages
      class NotePageTest < TestCase
        def note(index)
          fixture_site.notes[index]
        end

        def render_note(note, prev_note: nil, next_note: nil)
          parse_html(NotePage.new(site: fixture_site, note:, prev_note:, next_note:).call)
        end

        def meta(doc, key)
          doc.at_css("meta[property='#{key}'], meta[name='#{key}']")&.[]("content")
        end

        def test_titles_the_document_after_the_first_words_of_an_untitled_note
          doc = render_note(note(5))

          assert_equal "One two three four five six seven eight nine ten… · fixture|site", doc.at_css("title").text
          assert_equal "layout--note", doc.at_css("body")["class"]
        end

        def test_titles_a_short_untitled_note_after_its_text
          assert_equal "A plain note with no link. · fixture|site", render_note(note(0)).at_css("title").text
        end

        def test_titles_a_link_only_note_after_its_link
          assert_equal "Only a link · fixture|site", render_note(note(4)).at_css("title").text
        end

        def test_a_titled_note_uses_its_title_for_the_document_and_body
          doc = render_note(note(0).with(title: "A Titled Note"))

          assert_equal "A Titled Note · fixture|site", doc.at_css("title").text
          assert_equal "layout--note a-titled-note", doc.at_css("body")["class"]
          assert_equal "A Titled Note", doc.at_css("meta[property='og:title']")["content"]
        end

        def test_links_back_to_the_notes_stream
          assert_equal "Notes", render_note(note(0)).at_css("main a[href='/notes/']").text
        end

        def test_renders_the_note_entry
          entry = render_note(note(1)).at_css("main article.h-entry")

          assert_equal "/notes/2021/05/02/101500/", entry.at_css("a.u-url")["href"]
          assert_includes entry.text, "Look at this."
          assert_includes entry.text, "A wide preview"
        end

        def test_renders_a_youtube_player_with_its_script
          doc = render_note(note(3))
          scripts = doc.css("script").map(&:text).grep(/youtube-nocookie/)

          assert_equal "dQw4w9WgXcQ", doc.at_css("a[data-youtube-id]")["data-youtube-id"]
          assert_equal [Shared::YoutubeScript::SCRIPT], scripts
        end

        def test_renders_an_instagram_post
          doc = render_note(note(7))

          assert_equal "Instagram · @ada.example", doc.at_css("main a.instagram-card .card-source").text
          assert_empty doc.css("[data-youtube-id]")
        end

        def test_renders_a_bluesky_post
          doc = render_note(note(6))

          assert_equal "Bluesky · Ada · @ada.example.com", doc.at_css("main .bluesky-card a.card-source").text
          assert_empty doc.css("[data-youtube-id]")
        end

        def test_a_note_without_neighbours_has_no_pager
          doc = render_note(note(0))

          assert_nil doc.at_css("nav[aria-label='More notes']")
          assert_empty doc.css("a[rel=prev], a[rel=next]")
        end

        def test_links_to_older_and_newer_notes
          doc = render_note(note(2), prev_note: note(1), next_note: note(3))
          pager = doc.at_css("nav[aria-label='More notes']")

          assert_equal "← Older", pager.at_css("a[rel=prev]").text
          assert_equal "/notes/2021/05/02/101500/", pager.at_css("a[rel=prev]")["href"]
          assert_equal "Newer →", pager.at_css("a[rel=next]").text
          assert_equal "/notes/2021/05/04/080000/", pager.at_css("a[rel=next]")["href"]
        end

        def test_the_first_note_has_no_older_link
          pager = render_note(note(0), next_note: note(1)).at_css("nav[aria-label='More notes']")

          assert_nil pager.at_css("a[rel=prev]")
          assert_equal "/notes/2021/05/02/101500/", pager.at_css("a[rel=next]")["href"]
        end

        def test_the_last_note_has_no_newer_link
          pager = render_note(note(5), prev_note: note(4)).at_css("nav[aria-label='More notes']")

          assert_nil pager.at_css("a[rel=next]")
          assert_equal "/notes/2021/05/05/200000/", pager.at_css("a[rel=prev]")["href"]
        end

        def test_inlines_the_syntax_css_after_the_site_css
          assert_equal [fixture_site.css, fixture_site.syntax_css], render_note(note(0)).css("head style").map(&:text)
        end

        def test_seo_describes_the_note_as_an_article
          doc = render_note(note(0))

          assert_equal "https://example.test/notes/2021/05/01/093000/", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "article", meta(doc, "og:type")
          assert_equal "A plain note with no link.", meta(doc, "description")
          assert_equal "2021-05-01T09:30:00+02:00", meta(doc, "article:published_time")
          assert_equal "2021-05-01T09:30:00+02:00", meta(doc, "article:modified_time")
          assert_equal "BlogPosting", JSON.parse(doc.at_css("script[type='application/ld+json']").text)["@type"]
        end

        def test_seo_falls_back_to_the_site_description_for_a_note_without_text
          assert_equal "Fixture description", meta(render_note(note(4)), "description")
        end
      end
    end
  end
end
