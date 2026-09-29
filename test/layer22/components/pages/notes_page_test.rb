# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class NotesPageTest < TestCase
        NOTES_PAGE = <<~MD
          ---
          layout: notes
          title: Notes
          permalink: /notes/
          ---
        MD

        def youtube_note(hour, id)
          <<~MD
            ---
            date: 2021-05-01 #{hour}:00:00 +0200
            link:
              url: https://www.youtube.com/watch?v=#{id}
              youtube: #{id}
              title: Video #{id}
            ---

            Watch #{id}.
          MD
        end

        def render_notes_page(site = fixture_site)
          page = site.pages.find { |candidate| candidate.permalink == "/notes/" }
          parse_html(NotesPage.new(site:, page:).call)
        end

        def render_loaded_site(files)
          with_site(files) { render_notes_page(Site.new.load_content.load_css) }
        end

        def youtube_scripts(doc)
          doc.css("script").select { |script| script.text.include?("youtube-nocookie") }
        end

        def test_titles_the_document_and_body_after_the_page
          doc = render_notes_page

          assert_equal "Notes · fixture|site", doc.at_css("title").text
          assert_equal "layout--default notes", doc.at_css("body")["class"]
        end

        def test_heads_the_feed_with_the_title_and_an_rss_link
          feed = render_notes_page.at_css("main .h-feed")

          assert_equal "Notes", feed.at_css("h1").text
          assert_equal "RSS", feed.at_css("a[href='/notes/feed.xml']").text
        end

        def test_lists_every_note_newest_first
          entries = render_notes_page.css("main article.h-entry")

          assert_equal fixture_site.notes.reverse.map(&:permalink), entries.map { |entry| entry.at_css("a.u-url")["href"] }
          assert_equal 8, entries.size
        end

        def test_renders_note_bodies_and_link_previews
          text = render_notes_page.at_css("main").text

          assert_includes text, "A plain note with no link."
          assert_includes text, "A wide preview"
          assert_includes text, "Only a link"
        end

        def test_renders_the_youtube_player_script_once
          doc = render_notes_page

          assert_equal 1, doc.css("a[data-youtube-id]").size
          assert_equal [Shared::YoutubeScript::SCRIPT], youtube_scripts(doc).map(&:text)
        end

        def test_renders_the_youtube_script_once_for_several_videos
          doc = render_loaded_site(
            "_pages/notes.html" => NOTES_PAGE,
            "_notes/2021/05/2021-05-01-100000.md" => youtube_note("10", "aaaaaaaaaaa"),
            "_notes/2021/05/2021-05-01-110000.md" => youtube_note("11", "bbbbbbbbbbb")
          )

          assert_equal %w[bbbbbbbbbbb aaaaaaaaaaa], doc.css("a[data-youtube-id]").map { |a| a["data-youtube-id"] }
          assert_equal 1, youtube_scripts(doc).size
        end

        def test_renders_an_empty_stream_without_notes
          doc = render_loaded_site("_pages/notes.html" => NOTES_PAGE)

          assert_empty doc.css("article")
          assert_equal "Notes", doc.at_css("h1").text
        end

        def test_seo_describes_the_page
          doc = render_notes_page

          assert_equal "https://example.test/notes/", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "Fixture description", doc.at_css("meta[name=description]")["content"]
          assert_equal "website", doc.at_css("meta[property='og:type']")["content"]
        end
      end
    end
  end
end
