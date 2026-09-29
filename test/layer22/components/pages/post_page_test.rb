# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  module Components
    module Pages
      class PostPageTest < TestCase
        def hello_world
          fixture_site.posts[0]
        end

        def year_in_review
          fixture_site.posts[1]
        end

        def cafe
          fixture_site.posts[2]
        end

        def render_post(post = hello_world, site: fixture_site)
          parse_html(PostPage.new(site:, post:).call)
        end

        def meta(doc, key)
          doc.at_css("meta[property='#{key}'], meta[name='#{key}']")&.[]("content")
        end

        def test_titles_the_document_and_body_after_the_post
          doc = render_post

          assert_equal "Hello, World · fixture|site", doc.at_css("title").text
          assert_equal "layout--post hello-world", doc.at_css("body")["class"]
        end

        def test_renders_the_post_as_an_h_entry_with_its_title
          doc = render_post
          article = doc.at_css("main article")

          assert_includes article["class"].split, "h-entry"
          assert_equal "Hello, World", article.at_css("h1").text
        end

        def test_escapes_the_title
          title = %(<b>Bold</b> & "quoted")
          doc = render_post(hello_world.with(title:))

          assert_equal title, doc.at_css("article h1").text
          assert_equal "#{title} · fixture|site", doc.at_css("title").text
          assert_nil doc.at_css("article h1 b")
        end

        def test_links_back_to_the_archive
          kicker = render_post.at_css("article a[href='/archive']")

          assert_equal "Writing", kicker.text
        end

        def test_byline_names_the_author_with_an_h_card
          author = render_post.at_css("article a.p-author")

          assert_includes author["class"].split, "h-card"
          assert_equal "Ada Author", author.text
          assert_equal "https://example.test/", author["href"]
        end

        def test_byline_dates_the_post_and_links_to_its_permalink
          link = render_post.at_css("article a.u-url")
          time = link.at_css("time.dt-published")

          assert_equal "https://example.test/hello-world", link["href"]
          assert_equal "2019-03-14T00:00:00+01:00", time["datetime"]
          assert_equal "March 14, 2019", time.text
        end

        def test_byline_shows_the_reading_time
          assert_includes render_post.at_css("article .post-header").text, "1 min read"
          assert_includes render_post(hello_world.with(reading_time: 7)).at_css("article .post-header").text, "7 min read"
        end

        def test_tags_link_to_their_archives
          tags = render_post.css("article a[href^='/tags/']").map { |a| [a.text, a["href"]] }

          assert_equal [%w[ruby /tags/ruby], %w[rails /tags/rails]], tags
        end

        def test_tag_links_slugify_unicode_and_spaces
          tags = render_post(cafe.with(tags: ["Café", "Machine Learning"])).css("article a[href^='/tags/']").map { |a| a["href"] }

          assert_equal ["/tags/café", "/tags/machine-learning"], tags
        end

        def test_omits_tags_when_the_post_has_none
          doc = render_post(hello_world.with(tags: []))

          assert_empty doc.css("a[href^='/tags/']")
        end

        def test_renders_the_body_html_unescaped
          doc = render_post(year_in_review)
          body = doc.at_css("article .e-content")

          assert_equal "Raw HTML stays.", body.at_css("div.custom").text
          assert_equal 1, body.css("div.custom").size
        end

        def test_renders_highlighted_code_from_the_body
          body = render_post.at_css("article .e-content")

          assert body.at_css("div.highlighter-rouge pre code")
          assert_equal %w[setup setup-1], body.css("h2").map { |h2| h2["id"] }
        end

        def test_body_html_is_not_escaped
          body = render_post(hello_world.with(body_html: "<p>Some <em>emphasis</em> &amp; more</p>")).at_css("article .e-content")

          assert_equal "emphasis", body.at_css("p em").text
          assert_equal "Some emphasis & more", body.at_css("p").text
        end

        def test_shows_when_the_post_was_last_modified
          time = render_post.at_css("article time[datetime='2019-04-01T10:00:00+02:00']")

          assert_equal "Last modified April 1, 2019", time.text
        end

        def test_last_modified_date_is_in_the_sites_timezone
          time = render_post(year_in_review).css("article time").last

          assert_equal "2021-01-05T09:00:00+01:00", time["datetime"]
          assert_equal "Last modified January 5, 2021", time.text
        end

        def test_links_to_edit_the_post_on_github
          link = render_post.at_css("article a[href*='/edit/']")

          assert_equal "Edit on GitHub", link.text
          assert_equal "https://github.com/ada/fixture/edit/main/_posts/2019-03-14-hello-world.md", link["href"]
        end

        def test_edit_link_is_built_from_the_config
          config = {github: {"repository_url" => "https://github.com/grace/blog", "branch" => "trunk"}}
          with_site(config:) do
            link = render_post(site: Site.new.load_css).at_css("article a[href*='/edit/']")

            assert_equal "https://github.com/grace/blog/edit/trunk/_posts/2019-03-14-hello-world.md", link["href"]
          end
        end

        def test_adds_the_header_link_script_after_the_article
          doc = render_post
          script = doc.css("main > script").first

          assert_equal "script", doc.at_css("main article").next_element.name
          assert_includes script.text, "article.post h2[id], article.post h3[id]"
          assert_includes script.text, "header-link"
        end

        def test_article_has_the_class_the_header_link_script_selects
          assert_includes render_post.at_css("main article")["class"].split, "post"
        end

        def test_inlines_the_syntax_css_after_the_site_css
          styles = render_post.css("head style").map(&:text)

          assert_equal [fixture_site.css, fixture_site.syntax_css], styles
        end

        def test_seo_describes_the_post_as_an_article
          doc = render_post

          assert_equal "https://example.test/hello-world", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "article", meta(doc, "og:type")
          assert_equal "Hello, World", meta(doc, "og:title")
          assert_equal hello_world.description, meta(doc, "description")
          assert_equal "2019-03-14T00:00:00+01:00", meta(doc, "article:published_time")
          assert_equal "2019-04-01T10:00:00+02:00", meta(doc, "article:modified_time")
        end

        def test_json_ld_is_a_blog_posting
          data = JSON.parse(render_post(year_in_review).at_css("script[type='application/ld+json']").text)

          assert_equal "BlogPosting", data["@type"]
          assert_equal "Year — in review", data["headline"]
          assert_equal "What happened in 2020.", data["description"]
          assert_equal "2021-01-01T00:30:00+01:00", data["datePublished"]
          assert_equal "https://example.test/review", data["mainEntityOfPage"]["@id"]
        end
      end
    end
  end
end
