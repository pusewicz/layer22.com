# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class TaxonomyListingTest < TestCase
        def render_listing(taxonomy: "Tags", groups: fixture_site.tags)
          parse_html(TaxonomyListing.new(site: fixture_site, taxonomy:, groups:).call)
        end

        def test_labels_the_jump_menu_with_the_taxonomy
          assert_equal "Tags", render_listing.at_css("nav")["aria-label"]
          assert_equal "Categories", render_listing(taxonomy: "Categories", groups: fixture_site.categories).at_css("nav")["aria-label"]
        end

        def test_jump_menu_links_to_each_group_in_order
          links = render_listing.css("nav a").map { |a| [a.text, a["href"]] }

          assert_equal [%w[ruby #ruby], %w[rails #rails], %w[Café #café]], links
        end

        def test_each_group_has_a_heading_the_menu_jumps_to
          doc = render_listing

          assert_equal %w[ruby rails café], doc.css("h2").map { |h2| h2["id"] }
          assert_equal %w[ruby rails Café], doc.css("h2").map(&:text)
          doc.css("nav a").each { |a| assert doc.at_css("h2[id=\x27#{a["href"].delete_prefix("#")}\x27]"), "no heading for #{a["href"]}" }
        end

        def test_lists_each_groups_posts_after_its_heading
          doc = render_listing
          lists = doc.css("h2").to_h { |h2| [h2["id"], h2.next_element.css("li a").map { |a| a["href"] }] }

          assert_equal(
            {"ruby" => %w[/cafe /review /hello-world], "rails" => %w[/hello-world], "café" => %w[/cafe]},
            lists
          )
        end

        def test_labels_each_list_with_its_group
          labels = render_listing.css("ul").map { |ul| ul["aria-label"] }

          assert_equal ["posts classified under ruby", "posts classified under rails", "posts classified under Café"], labels
        end

        def test_slugifies_names_for_anchors
          doc = render_listing(groups: {"Machine Learning" => fixture_site.posts})

          assert_equal "#machine-learning", doc.at_css("nav a")["href"]
          assert_equal "Machine Learning", doc.at_css("nav a").text
          assert_equal "machine-learning", doc.at_css("h2")["id"]
        end

        def test_escapes_group_names
          name = %(<b>Bold</b> & "quoted")
          doc = render_listing(groups: {name => fixture_site.posts})

          assert_equal name, doc.at_css("nav a").text
          assert_equal name, doc.at_css("h2").text
          assert_nil doc.at_css("b")
        end

        def test_renders_only_an_empty_menu_without_groups
          doc = render_listing(groups: {})

          assert_empty doc.css("nav a")
          assert_empty doc.css("h2")
          assert_empty doc.css("ul")
        end
      end
    end
  end
end
