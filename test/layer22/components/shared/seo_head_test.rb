# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  module Components
    module Shared
      class SeoHeadTest < TestCase
        PUBLISHED = Time.new(2021, 3, 5, 8, 0, 0, "+01:00")
        MODIFIED = Time.new(2021, 4, 6, 9, 30, 0, "+02:00")

        def render_head(site: fixture_site, **)
          parse_html(SeoHead.new(site:, **).call)
        end

        def meta(doc, key)
          doc.at_css("meta[property='#{key}'], meta[name='#{key}']")&.[]("content")
        end

        def json_ld(doc)
          scripts = doc.css("script[type='application/ld+json']")
          assert_equal 1, scripts.size
          JSON.parse(scripts.first.text)
        end

        def test_home_uses_the_site_name_as_headline
          doc = render_head(kind: :home)

          assert_equal "fixture site", meta(doc, "og:title")
          assert_equal "fixture site", meta(doc, "twitter:title")
        end

        def test_site_name_replaces_pipes_with_spaces
          assert_equal "fixture site", meta(render_head, "og:site_name")
        end

        def test_title_is_the_headline
          doc = render_head(title: "A post")

          assert_equal "A post", meta(doc, "og:title")
          assert_equal "A post", meta(doc, "twitter:title")
          assert_equal "fixture site", meta(doc, "og:site_name")
        end

        def test_canonical_and_og_url_come_from_the_url
          doc = render_head(url: "/about")

          assert_equal "https://example.test/about", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "https://example.test/about", meta(doc, "og:url")
        end

        def test_url_defaults_to_the_home_page
          assert_equal "https://example.test/", render_head.at_css("link[rel=canonical]")["href"]
        end

        def test_description_is_used_when_given
          doc = render_head(description: "About this page.")

          assert_equal "About this page.", meta(doc, "description")
          assert_equal "About this page.", meta(doc, "og:description")
          assert_equal "About this page.", json_ld(doc)["description"]
        end

        def test_description_falls_back_to_the_site_description
          [nil, ""].each do |blank|
            doc = render_head(description: blank)

            assert_equal "Fixture description", meta(doc, "description")
            assert_equal "Fixture description", json_ld(doc)["description"]
          end
        end

        def test_description_is_one_tag_for_both_name_and_property
          tag = render_head.at_css("meta[name='twitter:description']")

          assert_equal "og:description", tag["property"]
        end

        def test_author_locale_and_twitter_tags_come_from_the_config
          doc = render_head

          assert_equal "Ada Author", meta(doc, "author")
          assert_equal "en_US", meta(doc, "og:locale")
          assert_equal "summary", meta(doc, "twitter:card")
          assert_equal "@fixturesite", meta(doc, "twitter:site")
          assert_equal "@ada", meta(doc, "twitter:creator")
        end

        def test_home_and_page_are_websites_without_article_times
          %i[home page].each do |kind|
            doc = render_head(kind:, published_at: PUBLISHED, modified_at: MODIFIED)

            assert_equal "website", meta(doc, "og:type")
            assert_nil meta(doc, "article:published_time")
            assert_nil meta(doc, "article:modified_time")
          end
        end

        def test_article_has_article_type_and_times
          doc = render_head(kind: :article, url: "/post", published_at: PUBLISHED, modified_at: MODIFIED)

          assert_equal "article", meta(doc, "og:type")
          assert_equal "2021-03-05T08:00:00+01:00", meta(doc, "article:published_time")
          assert_equal "2021-04-06T09:30:00+02:00", meta(doc, "article:modified_time")
        end

        def test_article_modified_time_defaults_to_published_time
          doc = render_head(kind: :article, published_at: PUBLISHED)

          assert_equal "2021-03-05T08:00:00+01:00", meta(doc, "article:modified_time")
          assert_equal "2021-03-05T08:00:00+01:00", json_ld(doc)["dateModified"]
        end

        def test_unknown_kind_raises
          error = assert_raises(ArgumentError) { SeoHead.new(site: fixture_site, kind: :video) }

          assert_match(/unknown SEO kind :video/, error.message)
        end

        def test_home_json_ld
          data = json_ld(render_head(kind: :home, modified_at: MODIFIED))

          assert_equal(
            {
              "@context" => "https://schema.org",
              "@type" => "WebSite",
              "author" => {"@type" => "Person", "name" => "Ada Author"},
              "dateModified" => "2021-04-06T09:30:00+02:00",
              "description" => "Fixture description",
              "headline" => "fixture site",
              "name" => "Ada Author",
              "publisher" => {
                "@type" => "Organization",
                "logo" => {"@type" => "ImageObject", "url" => "https://example.test/images/logo.png"},
                "name" => "Ada Author"
              },
              "sameAs" => ["https://github.com/ada", "https://social.example.test/@ada"],
              "url" => "https://example.test/"
            },
            data
          )
        end

        def test_article_json_ld
          data = json_ld(render_head(kind: :article, title: "A post", url: "/post", published_at: PUBLISHED, modified_at: MODIFIED))

          assert_equal "BlogPosting", data["@type"]
          assert_equal "A post", data["headline"]
          assert_equal "2021-03-05T08:00:00+01:00", data["datePublished"]
          assert_equal "2021-04-06T09:30:00+02:00", data["dateModified"]
          assert_equal({"@type" => "WebPage", "@id" => "https://example.test/post"}, data["mainEntityOfPage"])
          assert_equal "https://example.test/post", data["url"]
          assert_equal({"@type" => "Person", "name" => "Ada Author"}, data["author"])
          refute_includes data.keys, "sameAs"
          refute_includes data.keys, "name"
        end

        def test_page_json_ld_has_only_what_a_page_needs
          data = json_ld(render_head(title: "About", url: "/about", modified_at: MODIFIED))

          assert_equal "WebPage", data["@type"]
          assert_equal "2021-04-06T09:30:00+02:00", data["dateModified"]
          %w[datePublished mainEntityOfPage sameAs name].each { |key| refute_includes data.keys, key }
        end

        def test_json_ld_omits_date_modified_without_a_modified_time
          refute_includes json_ld(render_head(title: "About")).keys, "dateModified"
          refute_includes json_ld(render_head(kind: :home)).keys, "dateModified"
        end

        def test_json_ld_does_not_let_a_title_close_the_script
          title = "</script><script>alert(1)</script>"
          html = SeoHead.new(site: fixture_site, title:).call
          doc = parse_html(html)

          assert_equal 1, doc.css("script").size
          assert_equal title, json_ld(doc)["headline"]
          assert_includes html, "<\\/script>"
        end

        def test_escapes_attribute_values
          title = %(<b>&"')
          html = SeoHead.new(site: fixture_site, title:, description: %(<i>"quoted"</i>)).call
          doc = parse_html(html)

          assert_equal title, meta(doc, "og:title")
          assert_equal title, meta(doc, "twitter:title")
          assert_equal %(<i>"quoted"</i>), meta(doc, "description")
        end

        def test_reads_the_site_name_and_urls_from_the_config
          with_site(config: {title: "a|b|c", url: "https://other.test/", twitter: {"username" => "other"}}) do
            doc = render_head(site: Site.new, url: "/x")

            assert_equal "a b c", meta(doc, "og:site_name")
            assert_equal "https://other.test/x", doc.at_css("link[rel=canonical]")["href"]
            assert_equal "@other", meta(doc, "twitter:site")
          end
        end
      end
    end
  end
end
