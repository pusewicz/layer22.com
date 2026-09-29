# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class PostListItemTest < TestCase
        def item(post)
          parse_html(PostListItem.new(site: fixture_site, post:).call).at_css("p")
        end

        def test_links_the_title_to_the_post
          link = item(fixture_site.posts.first).at_css("a")

          assert_equal "/hello-world", link["href"]
          assert_equal "Hello, World", link.text
        end

        def test_renders_the_posts_date_and_reading_time
          item = item(fixture_site.posts.first)

          assert_equal "2019-03-14T00:00:00+01:00", item.at_css("time")["datetime"]
          assert_equal "1 min read", item.at_css(".word-count").text
        end

        def test_shows_the_decoded_title_from_front_matter
          assert_equal "Year — in review", item(fixture_site.posts[1]).at_css("a").text
        end

        def test_escapes_the_title
          title = %(<b>Bold</b> & "quoted")
          item = item(fixture_site.posts.first.with(title:))

          assert_equal title, item.at_css("a").text
          assert_nil item.at_css("b")
        end
      end
    end
  end
end
