# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class NavTest < TestCase
        def nav
          parse_html(Nav.new(site: fixture_site).call).at_css("nav")
        end

        def test_links_to_the_sections_of_the_site
          links = nav.css("a").reject { |a| a["href"] == "/" }.to_h { |a| [a.text, a["href"]] }

          assert_equal(
            {"Writing" => "/archive", "Notes" => "/notes/", "About" => "/about", "Resume" => "/resume", "Contact" => "/contact"},
            links
          )
        end

        def test_lists_the_sections_in_order
          labels = nav.css("a").reject { |a| a["href"] == "/" }.map(&:text)

          assert_equal %w[Writing Notes About Resume Contact], labels
        end

        def test_wordmark_links_home_and_spells_the_site_name
          wordmark = nav.at_css("a[href='/']")

          assert_equal "layer|twenty|two", wordmark.text
        end

        def test_wordmark_logo_is_decorative
          logo = nav.at_css("a[href='/'] img")

          assert_equal "/apple-touch-icon.png", logo["src"]
          assert_equal "", logo["alt"]
        end
      end
    end
  end
end
