# frozen_string_literal: true

require "yaml"

module Layer22
  Config = Data.define(
    :title,
    :tagline,
    :description,
    :url,
    :email,
    :author,
    :github_username,
    :github,
    :twitter,
    :mastodon,
    :social,
    :logo,
    :timezone,
    :words_per_minute,
    :webp
  ) do
    def self.load(path = "site.yml")
      data = YAML.safe_load_file(path, symbolize_names: false)
      new(
        title: data["title"],
        tagline: data["tagline"],
        description: data["description"],
        url: data["url"],
        email: data["email"],
        author: data["author"] || {},
        github_username: data["github_username"],
        github: data["github"] || {},
        twitter: data["twitter"] || {},
        mastodon: data["mastodon"] || {},
        social: data["social"] || {},
        logo: data["logo"],
        timezone: data["timezone"] || "UTC",
        words_per_minute: (data["words_per_minute"] || 180).to_f,
        webp: data["webp"] || {}
      )
    end

    def site_url
      url.chomp("/")
    end

    def author_name
      author["name"]
    end

    def mastodon_url
      "https://#{mastodon["instance"]}/@#{mastodon["username"]}"
    end

    def github_url
      "https://github.com/#{github_username}"
    end
  end
end
