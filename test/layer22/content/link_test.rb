# frozen_string_literal: true

require "test_helper"

module Layer22
  module Content
    class LinkTest < TestCase
      def test_from_front_matter_returns_nil_without_a_link
        assert_nil Link.from_front_matter(nil)
      end

      def test_from_front_matter_copies_the_saved_metadata
        data = {
          "url" => "https://www.example.org/wide",
          "site" => "Example Org",
          "youtube" => "dQw4w9WgXcQ",
          "title" => "A wide preview",
          "author" => "Someone",
          "description" => "Its description.",
          "image" => "/images/notes/wide.png"
        }
        link = Link.from_front_matter(data, root: FIXTURE_ROOT)

        assert_equal "https://www.example.org/wide", link.url
        assert_equal "Example Org", link.site
        assert_equal "dQw4w9WgXcQ", link.youtube
        assert_equal "A wide preview", link.title
        assert_equal "Someone", link.author
        assert_equal "Its description.", link.description
        assert_equal "/images/notes/wide.png", link.image
      end

      def test_from_front_matter_leaves_absent_metadata_nil
        link = Link.from_front_matter({"url" => "https://example.com/"})

        assert_equal "https://example.com/", link.url
        assert_nil link.site
        assert_nil link.youtube
        assert_nil link.bluesky
        assert_nil link.title
        assert_nil link.author
        assert_nil link.description
        assert_nil link.image
        assert_nil link.image_width
        assert_nil link.image_height
      end

      def test_from_front_matter_requires_a_url
        error = assert_raises(KeyError) { Link.from_front_matter({"title" => "No url"}) }

        assert_includes error.message, "url"
      end

      def test_from_front_matter_reads_a_bluesky_post
        link = Link.from_front_matter({"url" => "https://bsky.app/profile/a.test/post/1", "bluesky" => {"handle" => "a.test", "text" => "Hi"}})

        assert_equal BlueskyPost.new(handle: "a.test", text: "Hi", date: nil, lang: nil, alt: nil, facets: []), link.bluesky
      end

      def test_from_front_matter_reads_the_kind_of_an_instagram_post
        link = Link.from_front_matter({"url" => "https://www.instagram.com/reel/a/", "instagram" => "reel"})

        assert_equal "reel", link.instagram
        assert_nil Link.from_front_matter({"url" => "https://a.test/"}).instagram
      end

      def test_instagram_video_is_true_for_a_reel_only
        assert_predicate link(instagram: "reel"), :instagram_video?
        refute_predicate link(instagram: "post"), :instagram_video?
        refute_predicate link, :instagram_video?
      end

      def test_from_front_matter_reads_the_thumbnail_dimensions
        wide = Link.from_front_matter({"url" => "https://a.test/", "image" => "/images/notes/wide.png"}, root: FIXTURE_ROOT)
        square = Link.from_front_matter({"url" => "https://a.test/", "image" => "/images/notes/square.png"}, root: FIXTURE_ROOT)

        assert_equal [200, 100], [wide.image_width, wide.image_height]
        assert_equal [100, 100], [square.image_width, square.image_height]
      end

      def test_from_front_matter_resolves_the_thumbnail_against_the_working_directory_by_default
        link = in_fixture_site { Link.from_front_matter({"url" => "https://a.test/", "image" => "/images/notes/wide.png"}) }

        assert_equal [200, 100], [link.image_width, link.image_height]
      end

      def test_from_front_matter_accepts_a_thumbnail_path_without_a_leading_slash
        link = Link.from_front_matter({"url" => "https://a.test/", "image" => "images/notes/wide.png"}, root: FIXTURE_ROOT)

        assert_equal [200, 100], [link.image_width, link.image_height]
      end

      def test_from_front_matter_keeps_the_image_path_when_the_file_is_missing
        link = Link.from_front_matter({"url" => "https://a.test/", "image" => "/images/notes/missing.png"}, root: FIXTURE_ROOT)

        assert_equal "/images/notes/missing.png", link.image
        assert_nil link.image_width
        assert_nil link.image_height
      end

      def test_from_front_matter_leaves_dimensions_nil_when_the_file_is_not_an_image
        with_site({"images/notes/broken.png" => "not an image"}) do |dir|
          link = Link.from_front_matter({"url" => "https://a.test/", "image" => "/images/notes/broken.png"}, root: dir)

          assert_nil link.image_width
          assert_nil link.image_height
        end
      end

      def test_host_drops_a_leading_www
        assert_equal "example.org", link(url: "https://www.example.org/wide").host
      end

      def test_host_keeps_other_subdomains
        assert_equal "blog.example.org", link(url: "https://blog.example.org/post").host
      end

      def test_host_drops_www_only_as_a_prefix_of_the_host
        assert_equal "awww.example.org", link(url: "https://awww.example.org/").host
        assert_equal "example.org", link(url: "https://example.org/www.page").host
      end

      def test_host_ignores_the_path_and_query
        assert_equal "youtube.com", link(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ").host
      end

      def test_wide_image_is_false_at_exactly_five_to_four
        refute_predicate link(width: 200, height: 160), :wide_image?
        refute_predicate link(width: 5, height: 4), :wide_image?
      end

      def test_wide_image_is_true_just_beyond_five_to_four
        assert_predicate link(width: 201, height: 160), :wide_image?
        assert_predicate link(width: 6, height: 4), :wide_image?
      end

      def test_wide_image_is_false_just_inside_five_to_four
        refute_predicate link(width: 199, height: 160), :wide_image?
      end

      def test_wide_image_is_true_for_a_wide_thumbnail_and_false_for_a_square_one
        assert_predicate link(width: 200, height: 100), :wide_image?
        refute_predicate link(width: 100, height: 100), :wide_image?
        refute_predicate link(width: 100, height: 200), :wide_image?
      end

      def test_wide_image_is_false_without_dimensions
        refute_predicate link, :wide_image?
        refute_predicate link(width: 200), :wide_image?
        refute_predicate link(height: 100), :wide_image?
      end

      def test_wide_image_is_false_for_a_zero_height
        refute_predicate link(width: 200, height: 0), :wide_image?
      end

      private

      def link(url: "https://example.test/", width: nil, height: nil, instagram: nil)
        Link.new(url:, site: nil, youtube: nil, bluesky: nil, instagram:, title: nil, author: nil, description: nil, image: "/x.png", image_width: width, image_height: height)
      end
    end
  end
end
