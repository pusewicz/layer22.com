# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Shared
      class PostListTest < TestCase
        def list(posts: fixture_site.posts, **)
          parse_html(PostList.new(site: fixture_site, posts:, **).call).at_css("ul")
        end

        def test_renders_an_item_per_post_in_the_given_order
          links = list(posts: fixture_site.posts.reverse).css("li > p a").map { |a| [a.text, a["href"]] }

          assert_equal [["Café notes", "/cafe"], ["Year — in review", "/review"], ["Hello, World", "/hello-world"]], links
        end

        def test_each_item_shows_its_date_and_reading_time
          items = list.css("li")

          assert_equal 3, items.size
          assert(items.all? { |li| li.at_css("time[datetime]") && li.at_css(".word-count") })
        end

        def test_labels_the_list
          assert_equal "posts classified under ruby", list(label: "posts classified under ruby")["aria-label"]
        end

        def test_has_no_label_by_default
          assert_nil list["aria-label"]
        end

        def test_applies_the_list_class
          assert_equal "posts", list(list_class: "posts")["class"]
          assert_nil list["class"]
        end

        def test_renders_an_empty_list_for_no_posts
          assert_empty list(posts: []).css("li")
        end
      end
    end
  end
end
