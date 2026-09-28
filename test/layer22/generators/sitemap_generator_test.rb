# frozen_string_literal: true

require "test_helper"

module Layer22
  module Generators
    class SitemapGeneratorTest < TestCase
      SITEMAP = {"s" => "http://www.sitemaps.org/schemas/sitemap/0.9"}.freeze
      XMLSCHEMA_TIME = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}\z/
      FIXTURE_URLS = %w[
        /hello-world /review /cafe
        /til/2021/03/05/first-til/ /til/2021/03/20/second-til/ /til/2022/01/10/third-til/
        /notes/2021/05/01/093000/ /notes/2021/05/02/101500/ /notes/2021/05/03/121000/
        /notes/2021/05/04/080000/ /notes/2021/05/05/200000/ /notes/2021/05/06/070000/
        /
        /about /archive /categories /colophon /notes/ /tags /til
        /tags/ruby/ /tags/rails/ /tags/café/
        /2021/ /2019/ /2021/06/ /2021/01/ /2019/03/ /2021/06/01/ /2021/01/01/ /2019/03/14/
      ].freeze

      def test_sitemap_lists_every_indexable_page_in_order
        assert_equal FIXTURE_URLS.map { |path| "https://example.test#{path}" }, locs(fixture_sitemap)
      end

      def test_sitemap_uses_the_sitemap_namespace_and_schema_location
        urlset = fixture_sitemap.root

        assert_equal "urlset", urlset.name
        assert_equal SITEMAP["s"], urlset.namespace.href
        assert_equal "#{SITEMAP["s"]} #{SITEMAP["s"]}/sitemap.xsd",
          urlset.attribute_with_ns("schemaLocation", "http://www.w3.org/2001/XMLSchema-instance").value
      end

      def test_redirects_hidden_pages_and_not_found_are_left_out
        paths = locs(fixture_sitemap).map { |loc| loc.delete_prefix("https://example.test") }

        %w[/moved /hidden /404.html /old-review /2020/old-review.html].each { |path| refute_includes paths, path }
      end

      def test_pages_without_a_permalink_are_left_out
        assert(locs(fixture_sitemap).none? { |loc| loc.include?("no-permalink") })
      end

      def test_content_entries_use_their_last_modified_time
        doc = fixture_sitemap

        assert_equal "2019-04-01T10:00:00+02:00", lastmod(doc, "/hello-world")
        assert_equal "2021-01-05T09:00:00+01:00", lastmod(doc, "/review")
        assert_equal "2021-03-21T08:00:00+01:00", lastmod(doc, "/til/2021/03/20/second-til/")
        assert_equal "2021-05-02T10:15:00+02:00", lastmod(doc, "/notes/2021/05/02/101500/")
      end

      def test_home_page_is_last_modified_when_the_newest_post_was_published
        assert_equal "2021-06-01T00:00:00+02:00", lastmod(fixture_sitemap, "/")
      end

      def test_pages_have_a_last_modified_time
        doc = fixture_sitemap

        %w[/about /archive /colophon /notes/ /til].each do |path|
          assert_match XMLSCHEMA_TIME, lastmod(doc, path), path
        end
      end

      def test_archives_have_no_last_modified_time
        doc = fixture_sitemap

        %w[/tags/ruby/ /tags/café/ /2021/ /2021/06/ /2021/01/01/ /2019/03/14/].each do |path|
          assert_nil lastmod(doc, path), path
        end
      end

      def test_resume_pdf_is_left_out_when_the_file_does_not_exist
        refute_includes locs(fixture_sitemap), "https://example.test/piotr-usewicz-resume.pdf"
      end

      def test_resume_pdf_is_listed_when_the_file_exists
        with_site({"piotr-usewicz-resume.pdf" => "%PDF-1.4\n"}) do
          doc = sitemap

          assert_equal ["https://example.test/", "https://example.test/piotr-usewicz-resume.pdf"], locs(doc)
          assert_match XMLSCHEMA_TIME, lastmod(doc, "/piotr-usewicz-resume.pdf")
        end
      end

      def test_site_without_content_lists_only_the_home_page_without_a_last_modified_time
        with_site do
          doc = sitemap

          assert_equal ["https://example.test/"], locs(doc)
          assert_nil lastmod(doc, "/")
        end
      end

      def test_locs_use_the_site_url_without_its_trailing_slash
        with_site({"_posts/2021-03-01-hi.md" => "---\ntitle: Hi\n---\n\nBody.\n"}, config: {url: "https://example.test/"}) do
          assert_equal %w[
            https://example.test/hi https://example.test/
            https://example.test/2021/ https://example.test/2021/03/ https://example.test/2021/03/01/
          ], locs(sitemap)
        end
      end

      def test_generate_writes_sitemap_xml
        Dir.mktmpdir do |dir|
          out, = in_fixture_site { capture_io { SitemapGenerator.new(Site.new.load_content).generate(output_dir: dir) } }

          path = File.join(dir, "sitemap.xml")
          assert_equal "Generated #{path}\n", out
          assert_equal FIXTURE_URLS.size, parse_xml(File.read(path)).xpath("/s:urlset/s:url", SITEMAP).size
        end
      end

      private

      # The sitemap of the site in the working directory. Its lastmod times come
      # from files there, so it has to be built with the site's directory current.
      def sitemap
        parse_xml(SitemapGenerator.new(Site.new.load_content).build_sitemap)
      end

      def fixture_sitemap
        @fixture_sitemap ||= in_fixture_site { sitemap }
      end

      def locs(doc)
        doc.xpath("/s:urlset/s:url/s:loc", SITEMAP).map(&:text)
      end

      def lastmod(doc, path)
        doc.at_xpath("/s:urlset/s:url[s:loc='https://example.test#{path}']/s:lastmod", SITEMAP)&.text
      end
    end
  end
end
