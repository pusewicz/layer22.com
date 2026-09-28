# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class LinkCardTest < TestCase
        def link(**overrides)
          Content::Link.new(
            url: "https://www.example.org/page", site: nil, youtube: nil, title: nil, author: nil, description: nil,
            image: nil, image_width: nil, image_height: nil, **overrides
          )
        end

        def render_card(link)
          parse_html(LinkCard.new(site: fixture_site, link:).call).at_css("a")
        end

        def texts(card)
          card.css("div").select { |div| div.css("div").empty? }.map(&:text)
        end

        def test_the_whole_card_is_one_link_to_the_page
          doc = parse_html(LinkCard.new(site: fixture_site, link: link).call)

          assert_equal ["https://www.example.org/page"], doc.css("a").map { |a| a["href"] }
          assert_equal "a", doc.at_css("body").element_children.first.name
        end

        def test_shows_source_title_and_description
          link = fixture_site.notes[1].link

          assert_equal ["Example Org · Someone", "A wide preview", "Its description."], texts(render_card(link))
        end

        def test_wide_image_runs_above_the_text_at_its_own_size
          card = render_card(fixture_site.notes[1].link)
          image = card.at_css("> img")

          assert_equal "/images/notes/wide.png", image["src"]
          assert_equal "", image["alt"]
          assert_equal %w[200 100], [image["width"], image["height"]]
          assert_equal "lazy", image["loading"]
          assert_equal 1, card.css("img").size
          assert_equal %w[img div], card.element_children.map(&:name)
        end

        def test_square_image_is_a_thumbnail_beside_the_text
          card = render_card(fixture_site.notes[2].link)
          thumbnail = card.at_css("> div img")

          assert_nil card.at_css("> img")
          assert_equal "/images/notes/square.png", thumbnail["src"]
          assert_equal "", thumbnail["alt"]
          assert_equal %w[80 80], [thumbnail["width"], thumbnail["height"]]
          assert_equal "lazy", thumbnail["loading"]
          assert_equal %w[div img], card.at_css("> div").element_children.map(&:name)
        end

        def test_image_of_unknown_size_is_a_thumbnail
          card = render_card(link(image: "/images/notes/unknown.png"))

          assert_nil card.at_css("> img")
          assert_equal "/images/notes/unknown.png", card.at_css("> div img")["src"]
        end

        def test_images_up_to_five_by_four_are_thumbnails
          five_by_four = render_card(link(image: "/a.png", image_width: 100, image_height: 80))
          wider = render_card(link(image: "/a.png", image_width: 101, image_height: 80))

          assert_nil five_by_four.at_css("> img")
          assert wider.at_css("> img")
        end

        def test_has_no_image_without_one
          assert_empty render_card(link(title: "A page")).css("img")
        end

        def test_source_is_site_and_author
          assert_equal "Example Org · Someone", texts(render_card(link(site: "Example Org", author: "Someone"))).first
        end

        def test_source_is_the_site_alone_without_an_author
          assert_equal "Example Org", texts(render_card(link(site: "Example Org"))).first
        end

        def test_source_falls_back_to_the_host_without_a_site
          assert_equal "example.org", texts(render_card(link)).first
          assert_equal "example.org · Someone", texts(render_card(link(author: "Someone"))).first
        end

        def test_title_falls_back_to_the_url
          assert_equal ["example.org", "https://www.example.org/page"], texts(render_card(link))
        end

        def test_description_is_optional
          assert_equal 2, texts(render_card(link(title: "A page"))).size
          assert_equal 3, texts(render_card(link(title: "A page", description: "About it."))).size
        end

        def test_escapes_text
          text = %(<b>Bold</b> & "quoted")
          card = render_card(link(site: text, title: text, description: text))

          assert_equal [text, text, text], texts(card)
          assert_nil card.at_css("b")
        end
      end
    end
  end
end
