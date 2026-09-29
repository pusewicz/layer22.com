# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class BlueskyCardTest < TestCase
        POST_URL = "https://bsky.app/profile/ada.example.com/post/3kabc"

        def link
          fixture_site.notes[6].link
        end

        def with_post(**overrides)
          link.with(bluesky: link.bluesky.with(**overrides))
        end

        def render_card(link = self.link)
          parse_html(BlueskyCard.new(site: fixture_site, link:).call).at_css(".bluesky-card")
        end

        def test_the_fixture_note_is_a_bluesky_post
          assert_equal POST_URL, link.url
          assert_equal "ada.example.com", link.bluesky.handle
        end

        def test_source_is_site_author_and_handle_linking_to_the_post
          source = render_card.at_css("a.card-source")

          assert_equal "Bluesky · Ada · @ada.example.com", source.text
          assert_equal POST_URL, source["href"]
        end

        def test_source_falls_back_to_bluesky_and_leaves_out_an_unknown_author
          card = render_card(link.with(site: nil, author: nil))

          assert_equal "Bluesky · @ada.example.com", card.at_css("a.card-source").text
        end

        def test_text_keeps_its_links_and_its_lines
          text = render_card.at_css(".bluesky-card-text")

          assert_equal "Café ☕ notes at example.com #lisp\nSecond line", text.text
          assert_equal %w[https://example.com/ https://bsky.app/hashtag/lisp], text.css("a").map { |a| a["href"] }
          assert_equal %w[example.com #lisp], text.css("a").map(&:text)
        end

        def test_text_states_its_language
          assert_equal "en", render_card.at_css(".bluesky-card-text")["lang"]
        end

        def test_text_has_no_language_when_the_post_does_not_say
          assert_nil render_card(with_post(lang: nil)).at_css(".bluesky-card-text")["lang"]
        end

        def test_text_sits_beside_its_links_not_inside_a_link
          text = render_card.at_css(".bluesky-card-text")

          assert_equal "bluesky-card-body", text.parent["class"]
          assert_equal "div", text.parent.name
        end

        def test_text_is_escaped
          card = render_card(with_post(text: "<script>alert(1)</script> & <b>bold</b>", facets: []))

          assert_nil card.at_css("script, b")
          assert_equal "<script>alert(1)</script> & <b>bold</b>", card.at_css(".bluesky-card-text").text
        end

        def test_link_text_is_escaped
          facet = Content::BlueskyPost::Facet.new(from: 0, to: 6, url: "https://a.test/?a=1&b=2")

          card = render_card(with_post(text: "<i>hi<", facets: [facet]))

          assert_nil card.at_css("i")
          assert_equal "<i>hi<", card.at_css(".bluesky-card-text a").text
          assert_equal "https://a.test/?a=1&b=2", card.at_css(".bluesky-card-text a")["href"]
        end

        def test_a_post_without_text_has_no_text_block
          assert_nil render_card(with_post(text: "")).at_css(".bluesky-card-text")
        end

        def test_image_links_to_the_post_with_its_alt_text_and_size
          media = render_card.at_css("a.bluesky-card-media")
          image = media.at_css("img")

          assert_equal POST_URL, media["href"]
          assert_nil media["aria-hidden"]
          assert_equal "/images/notes/wide.png", image["src"]
          assert_equal "A wide test image", image["alt"]
          assert_equal %w[200 100], [image["width"], image["height"]]
          assert_equal "lazy", image["loading"]
        end

        def test_image_comes_before_the_text
          card = render_card

          assert_equal %w[bluesky-card-media bluesky-card-body], card.element_children.map { |child| child["class"] }
        end

        def test_an_image_without_alt_text_is_hidden_from_assistive_technology
          media = render_card(with_post(alt: nil)).at_css("a.bluesky-card-media")

          assert_equal "", media.at_css("img")["alt"]
          assert_equal "true", media["aria-hidden"]
          assert_equal "-1", media["tabindex"]
        end

        def test_an_image_of_unknown_size_has_no_dimensions
          image = render_card(link.with(image_width: nil, image_height: nil)).at_css("img")

          assert_nil image["width"]
          assert_nil image["height"]
        end

        def test_a_post_without_an_image_has_no_media
          card = render_card(link.with(image: nil))

          assert_nil card.at_css(".bluesky-card-media")
          assert_nil card.at_css("img")
        end

        def test_date_is_shown_in_the_local_zone_and_links_to_the_post
          date = render_card.at_css("a.bluesky-card-date")

          assert_equal POST_URL, date["href"]
          assert_equal "2021-05-07T00:30:00+02:00", date.at_css("time")["datetime"]
          assert_equal "May 7, 2021", date.text
        end

        def test_a_post_without_a_date_has_no_date
          assert_nil render_card(with_post(date: nil)).at_css("time, .bluesky-card-date")
        end
      end
    end
  end
end
