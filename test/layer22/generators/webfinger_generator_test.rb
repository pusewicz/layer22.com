# frozen_string_literal: true

require "test_helper"
require "json"

module Layer22
  module Generators
    class WebfingerGeneratorTest < TestCase
      def test_generate_writes_the_webfinger_document
        Dir.mktmpdir do |dir|
          out, = capture_io { WebfingerGenerator.new(fixture_site).generate(output_dir: dir) }

          path = File.join(dir, ".well-known", "webfinger")
          assert_equal "Generated #{path}\n", out
          assert_equal({
            "subject" => "acct:ada@social.example.test",
            "aliases" => ["https://social.example.test/@ada", "https://social.example.test/users/ada"],
            "links" => [
              {"rel" => "http://webfinger.net/rel/profile-page", "type" => "text/html", "href" => "https://social.example.test/@ada"},
              {"rel" => "self", "type" => "application/activity+json", "href" => "https://social.example.test/users/ada"}
            ]
          }, JSON.parse(File.read(path)))
        end
      end

      def test_generate_creates_the_well_known_directory
        Dir.mktmpdir do |dir|
          refute File.exist?(File.join(dir, ".well-known"))

          capture_io { WebfingerGenerator.new(fixture_site).generate(output_dir: dir) }

          assert File.directory?(File.join(dir, ".well-known"))
        end
      end

      def test_document_follows_the_configured_account
        with_site({}, config: {mastodon: {"username" => "grace", "instance" => "mastodon.example"}}) do
          Dir.mktmpdir do |dir|
            capture_io { WebfingerGenerator.new(Site.new).generate(output_dir: dir) }

            document = JSON.parse(File.read(File.join(dir, ".well-known", "webfinger")))
            assert_equal "acct:grace@mastodon.example", document["subject"]
            assert_equal "https://mastodon.example/users/grace", document["links"].last["href"]
          end
        end
      end

      def test_no_file_is_written_without_a_mastodon_account
        [{}, nil, {"username" => "ada"}, {"instance" => "social.example.test"}].each do |mastodon|
          with_site({}, config: {mastodon:}) do
            Dir.mktmpdir do |dir|
              out, = capture_io { WebfingerGenerator.new(Site.new).generate(output_dir: dir) }

              assert_empty out, "mastodon: #{mastodon.inspect}"
              assert_empty Dir.children(dir), "mastodon: #{mastodon.inspect}"
            end
          end
        end
      end
    end
  end
end
