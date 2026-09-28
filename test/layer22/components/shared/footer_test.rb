# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class FooterTest < TestCase
        def render_footer(site: fixture_site)
          parse_html(Footer.new(site:).call).at_css("footer")
        end

        def link(footer, text)
          footer.css("a").find { |a| a.text == text }
        end

        def test_shows_the_current_year_and_author
          assert_equal "© #{Time.now.year} Ada Author", render_footer.at_css("p").text
        end

        def test_author_comes_from_the_config
          with_site(config: {author: {"name" => "Grace Hopper"}}) do
            assert_match(/\A© \d{4} Grace Hopper\z/, render_footer(site: Site.new).at_css("p").text)
          end
        end

        def test_links_to_the_authors_profiles_as_rel_me
          footer = render_footer

          assert_equal "https://github.com/ada", link(footer, "GitHub")["href"]
          assert_equal "me", link(footer, "GitHub")["rel"]
          assert_equal "https://social.example.test/@ada", link(footer, "Mastodon")["href"]
          assert_equal "me", link(footer, "Mastodon")["rel"]
        end

        def test_profile_links_come_from_the_config
          with_site(config: {github_username: "grace", mastodon: {"instance" => "hachyderm.test", "username" => "grace"}}) do
            footer = render_footer(site: Site.new)

            assert_equal "https://github.com/grace", link(footer, "GitHub")["href"]
            assert_equal "https://hachyderm.test/@grace", link(footer, "Mastodon")["href"]
          end
        end

        def test_links_to_bluesky_with_the_atproto_relation
          bluesky = link(render_footer, "Bluesky")

          assert_equal "https://bsky.app/profile/pusewicz.bsky.social", bluesky["href"]
          assert_equal %w[me atproto], bluesky["rel"].split
        end

        def test_links_to_iheartrss
          assert_equal "https://iheartrss.com/", link(render_footer, "I ♥ RSS")["href"]
        end

        def test_mentions_the_game_studio
          aside = render_footer.css("p").last

          assert_equal "Pssst—I also run a game studio.", aside.text
          assert_equal "https://layer22.games/", aside.at_css("a")["href"]
        end
      end
    end
  end
end
