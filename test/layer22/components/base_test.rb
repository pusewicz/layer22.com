# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    class BaseTest < TestCase
      class Probe < Base
        public :config, :format_date, :reading_time_label, :slugify, :absolute_url, :tag_url
      end

      def probe(site = fixture_site)
        Probe.new(site:)
      end

      def test_requires_a_site
        assert_raises(ArgumentError) { Probe.new }
      end

      def test_config_is_the_sites_config
        assert_same fixture_site.config, probe.config
      end

      def test_format_date_defaults_to_long_form_without_zero_padding
        assert_equal "March 5, 2019", probe.format_date(Time.new(2019, 3, 5, 12, 0, 0, "+01:00"))
      end

      def test_format_date_accepts_a_format
        assert_equal "05/03/19", probe.format_date(Time.new(2019, 3, 5, 12, 0, 0, "+01:00"), "%d/%m/%y")
      end

      def test_format_date_is_nil_for_nil
        assert_nil probe.format_date(nil)
      end

      def test_reading_time_label
        assert_equal "1 min read", probe.reading_time_label(1)
        assert_equal "12 min read", probe.reading_time_label(12)
      end

      def test_slugify_delegates_to_the_jekyll_compatible_slug
        assert_equal "café-notes", probe.slugify("Café Notes!")
      end

      def test_slugify_of_nil_is_empty
        assert_equal "", probe.slugify(nil)
      end

      def test_absolute_url_prefixes_the_site_url
        assert_equal "https://example.test/about", probe.absolute_url("/about")
      end

      def test_absolute_url_does_not_double_a_trailing_slash_in_the_site_url
        with_site(config: {url: "https://example.test/"}) do
          assert_equal "https://example.test/about", probe(Site.new).absolute_url("/about")
        end
      end

      def test_tag_url_slugifies_the_tag
        assert_equal "/tags/ruby", probe.tag_url("ruby")
        assert_equal "/tags/machine-learning", probe.tag_url("Machine Learning")
        assert_equal "/tags/café", probe.tag_url("Café")
      end
    end
  end
end
