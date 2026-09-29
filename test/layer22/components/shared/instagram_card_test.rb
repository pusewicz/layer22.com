# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class InstagramCardTest < TestCase
        REEL_URL = "https://www.instagram.com/reel/AbC-123xyz_/"

        def link(**overrides)
          fixture_site.notes[7].link.with(**overrides)
        end

        def render_card(link = self.link)
          parse_html(InstagramCard.new(site: fixture_site, link:).call).at_css("a")
        end

        def test_the_fixture_note_is_an_instagram_reel
          assert_equal REEL_URL, link.url
          assert_equal "reel", link.instagram
        end

        def test_the_whole_card_is_one_link_to_the_post
          card = render_card

          assert_equal REEL_URL, card["href"]
          assert_includes card["class"].split, "link-card"
          assert_includes card["class"].split, "instagram-card"
        end

        def test_source_is_site_and_handle
          assert_equal "Instagram · @ada.example", render_card.at_css(".card-source").text
        end

        def test_source_falls_back_to_instagram_and_leaves_out_an_unknown_author
          card = render_card(link(site: nil, author: nil))

          assert_equal "Instagram", card.at_css(".card-source").text
        end

        def test_shows_the_caption
          assert_equal "A short caption for the reel.", render_card.at_css(".link-card-description").text
        end

        def test_a_post_without_a_caption_has_no_description
          assert_nil render_card(link(description: nil)).at_css(".link-card-description")
        end

        def test_has_no_title
          assert_nil render_card.at_css(".card-title")
        end

        def test_text_is_escaped
          card = render_card(link(author: "<b>ada</b>", description: "<script>alert(1)</script> & more"))

          assert_nil card.at_css("b, script")
          assert_equal "Instagram · @<b>ada</b>", card.at_css(".card-source").text
          assert_equal "<script>alert(1)</script> & more", card.at_css(".link-card-description").text
        end

        def test_thumbnail_is_shown_lazily_with_its_size_and_no_alt_text
          image = render_card.at_css(".instagram-card-media img")

          assert_equal "/images/notes/square.png", image["src"]
          assert_equal "", image["alt"]
          assert_equal %w[100 100], [image["width"], image["height"]]
          assert_equal "lazy", image["loading"]
        end

        def test_thumbnail_comes_before_the_text
          card = render_card

          assert_equal %w[instagram-card-media link-card-body], card.element_children.map { |child| child["class"] }
        end

        def test_a_reel_has_a_decorative_play_button
          play = render_card.at_css(".instagram-card-media svg")

          assert_equal "true", play["aria-hidden"]
          assert_includes play["class"].split, "instagram-card-play"
        end

        def test_a_photo_post_has_no_play_button
          assert_nil render_card(link(instagram: "post")).at_css("svg")
        end

        def test_a_post_without_a_thumbnail_has_no_media_or_play_button
          card = render_card(link(image: nil))

          assert_nil card.at_css(".instagram-card-media, img, svg")
          assert_equal "Instagram · @ada.example", card.at_css(".card-source").text
        end

        def test_a_thumbnail_of_unknown_size_has_no_dimensions
          image = render_card(link(image_width: nil, image_height: nil)).at_css("img")

          assert_nil image["width"]
          assert_nil image["height"]
        end
      end
    end
  end
end
