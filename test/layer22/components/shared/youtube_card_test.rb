# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class YoutubeCardTest < TestCase
        WATCH_URL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

        def video(**overrides)
          fixture_site.notes[3].link.with(**overrides)
        end

        def render_card(link = video, **)
          parse_html(YoutubeCard.new(site: fixture_site, link:, **).call)
        end

        def caption(doc)
          doc.css("a").last.css("div").map(&:text)
        end

        def test_thumbnail_links_to_the_video_and_carries_its_id_for_the_player_script
          player = render_card.at_css("a[data-youtube-id]")

          assert_equal "dQw4w9WgXcQ", player["data-youtube-id"]
          assert_equal WATCH_URL, player["href"]
          assert_equal "Play A video", player["aria-label"]
        end

        def test_uses_youtubes_thumbnail_loaded_lazily
          image = render_card.at_css("a[data-youtube-id] img")

          assert_equal "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg", image["src"]
          assert_equal "", image["alt"]
          assert_equal %w[480 360], [image["width"], image["height"]]
          assert_equal "lazy", image["loading"]
        end

        def test_overlays_a_decorative_play_button
          play = render_card.at_css("a[data-youtube-id] svg")

          assert_equal "true", play["aria-hidden"]
          assert_equal 2, play.css("path").size
        end

        def test_caption_links_to_the_video_with_source_and_title
          doc = render_card
          link = doc.css("a").last

          assert_equal 2, doc.css("a").size
          assert_equal WATCH_URL, link["href"]
          assert_nil link["data-youtube-id"]
          assert_equal ["YouTube · A channel", "A video"], caption(doc)
        end

        def test_feed_mode_is_a_plain_thumbnail_link
          doc = render_card(feed: true)
          image = doc.at_css("a img")

          assert_equal [WATCH_URL, WATCH_URL], doc.css("a").map { |a| a["href"] }
          assert_empty doc.css("[data-youtube-id]")
          assert_empty doc.css("[aria-label]")
          assert_empty doc.css("svg")
          assert_equal "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg", image["src"]
          assert_nil image["loading"]
        end

        def test_feed_mode_keeps_the_caption
          assert_equal ["YouTube · A channel", "A video"], caption(render_card(feed: true))
        end

        def test_source_falls_back_to_youtube_without_a_site
          assert_equal "YouTube · A channel", caption(render_card(video(site: nil))).first
        end

        def test_source_is_the_site_alone_without_an_author
          assert_equal "YouTube", caption(render_card(video(author: nil))).first
          assert_equal "Vimeo", caption(render_card(video(site: "Vimeo", author: nil))).first
        end

        def test_title_falls_back_to_a_generic_label_and_the_watch_url
          doc = render_card(video(title: nil))

          assert_equal "Play video", doc.at_css("[data-youtube-id]")["aria-label"]
          assert_equal WATCH_URL, caption(doc).last
        end

        def test_title_fallback_in_feed_mode_is_the_watch_url
          assert_equal WATCH_URL, caption(render_card(video(title: nil), feed: true)).last
        end

        def test_escapes_the_title
          title = %(<b>Bold</b> & "quoted")
          doc = render_card(video(title:))

          assert_equal title, caption(doc).last
          assert_equal "Play #{title}", doc.at_css("[data-youtube-id]")["aria-label"]
          assert_nil doc.at_css("b")
        end
      end
    end
  end
end
