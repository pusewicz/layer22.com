# frozen_string_literal: true

require "json"

module Layer22
  module Generators
    class WebfingerGenerator
      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        return unless @config.mastodon["username"] && @config.mastodon["instance"]

        username = @config.mastodon["username"]
        instance = @config.mastodon["instance"]
        email = @config.email

        data = {
          subject: "acct:#{username}@#{instance}",
          aliases: [
            "https://#{instance}/@#{username}",
            "https://#{instance}/users/#{username}"
          ],
          links: [
            {
              rel: "http://webfinger.net/rel/profile-page",
              type: "text/html",
              href: "https://#{instance}/@#{username}"
            },
            {
              rel: "self",
              type: "application/activity+json",
              href: "https://#{instance}/users/#{username}"
            }
          ]
        }

        dest_dir = File.join(output_dir, ".well-known")
        FileUtils.mkdir_p(dest_dir)

        dest = File.join(dest_dir, "webfinger")
        File.write(dest, JSON.pretty_generate(data))
        puts "Generated #{dest}"
      end
    end
  end
end
