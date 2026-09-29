# frozen_string_literal: true

require "test_helper"

module Layer22
  class ConfigTest < TestCase
    FIXTURE_CONFIG = File.join(FIXTURE_ROOT, "site.yml")

    def test_load_reads_every_value_of_the_fixture_config
      config = Config.load(FIXTURE_CONFIG)

      assert_equal "fixture|site", config.title
      assert_equal "A fixture tagline", config.tagline
      assert_equal "Fixture description", config.description
      assert_equal "https://example.test", config.url
      assert_equal "ada@example.test", config.email
      assert_equal({"name" => "Ada Author", "twitter" => "ada"}, config.author)
      assert_equal "ada", config.github_username
      assert_equal({"repository_url" => "https://github.com/ada/fixture", "branch" => "main"}, config.github)
      assert_equal({"username" => "fixturesite"}, config.twitter)
      assert_equal({"username" => "ada", "instance" => "social.example.test"}, config.mastodon)
      assert_equal "Ada Author", config.social["name"]
      assert_equal ["https://github.com/ada", "https://social.example.test/@ada"], config.social["links"]
      assert_equal "/images/logo.png", config.logo
      assert_equal "Europe/Madrid", config.timezone
      assert_equal({"quality" => 80, "img_dirs" => ["images"]}, config.webp)
    end

    def test_load_converts_words_per_minute_to_a_float
      assert_equal 100.0, Config.load(FIXTURE_CONFIG).words_per_minute
      assert_instance_of Float, Config.load(FIXTURE_CONFIG).words_per_minute
    end

    def test_load_defaults_to_site_yml_in_the_working_directory
      with_site(config: {"title" => "From the working directory"}) do
        assert_equal "From the working directory", Config.load.title
      end
    end

    def test_load_applies_defaults_for_missing_keys
      config = load_yaml("title: Bare\nurl: https://bare.test\n")

      assert_equal "UTC", config.timezone
      assert_equal 180.0, config.words_per_minute
      assert_instance_of Float, config.words_per_minute
      assert_equal({}, config.author)
      assert_equal({}, config.github)
      assert_equal({}, config.twitter)
      assert_equal({}, config.mastodon)
      assert_equal({}, config.social)
      assert_equal({}, config.webp)
    end

    def test_load_leaves_missing_scalars_nil
      config = load_yaml("title: Bare\nurl: https://bare.test\n")

      assert_nil config.tagline
      assert_nil config.description
      assert_nil config.email
      assert_nil config.github_username
      assert_nil config.logo
    end

    def test_load_treats_empty_sections_like_missing_ones
      config = load_yaml("url: https://bare.test\nauthor:\nwebp:\n")

      assert_equal({}, config.author)
      assert_equal({}, config.webp)
    end

    def test_load_ignores_unknown_keys
      config = load_yaml("url: https://bare.test\nplugins:\n  - jekyll-feed\n")

      assert_equal "https://bare.test", config.url
    end

    def test_load_accepts_words_per_minute_as_a_string
      assert_equal 250.0, load_yaml("url: https://bare.test\nwords_per_minute: \"250\"\n").words_per_minute
    end

    def test_load_raises_for_a_missing_file
      assert_raises(Errno::ENOENT) { Config.load("/nonexistent/site.yml") }
    end

    def test_site_url_drops_a_trailing_slash
      assert_equal "https://example.test", Config.load(FIXTURE_CONFIG).site_url
      assert_equal "https://slash.test", load_yaml("url: https://slash.test/\n").site_url
    end

    def test_author_name_reads_the_author_section
      assert_equal "Ada Author", Config.load(FIXTURE_CONFIG).author_name
      assert_nil load_yaml("url: https://bare.test\n").author_name
    end

    def test_mastodon_url_combines_instance_and_username
      assert_equal "https://social.example.test/@ada", Config.load(FIXTURE_CONFIG).mastodon_url
    end

    def test_github_url_uses_the_github_username
      assert_equal "https://github.com/ada", Config.load(FIXTURE_CONFIG).github_url
    end

    def test_config_is_immutable
      config = Config.load(FIXTURE_CONFIG)

      assert_predicate config, :frozen?
      assert_raises(NoMethodError) { config.title = "Other" }
    end

    private

    def load_yaml(yaml)
      Dir.mktmpdir("layer22-config") do |dir|
        path = File.join(dir, "site.yml")
        File.write(path, yaml)
        Config.load(path)
      end
    end
  end
end
