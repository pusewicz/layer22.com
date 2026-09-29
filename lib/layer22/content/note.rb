# frozen_string_literal: true

require "nokogiri"

module Layer22
  module Content
    # A short, usually untitled note from _notes/, optionally pointing at a link.
    Note = Data.define(
      :title,
      :slug,
      :date,
      :tags,
      :description,
      :body_html,
      :link,
      :last_modified_at,
      :relative_path,
      :permalink
    ) do
      def self.load_all(dir = "_notes")
        Dir.glob("#{dir}/**/*.{md,markdown}").sort.map { |path| load_from_file(path) }
      end

      def self.load_from_file(path)
        front_matter, body = FrontMatter.parse(File.read(path, encoding: "UTF-8"))
        filename = File.basename(path, ".*")
        date = Timestamp.parse(front_matter["date"] || filename[/\A\d{4}-\d{2}-\d{2}/], source: path) || Time.now
        slug = filename.sub(/\A\d{4}-\d{2}-\d{2}-/, "")
        excerpt = Rendering::Excerpt.from_markdown(body)

        new(
          title: FrontMatter.text(front_matter["title"]).to_s,
          slug:,
          date:,
          tags: FrontMatter.list(front_matter, "tag", "tags"),
          description: front_matter["description"] || (excerpt unless excerpt.empty?),
          body_html: Rendering::Markdown.render(body).strip,
          link: Link.from_front_matter(front_matter["link"]),
          last_modified_at: Timestamp.parse(front_matter["last_modified_at"], source: path) || LastModified.for(path),
          relative_path: path,
          permalink: "/notes/#{date.strftime("%Y/%m/%d")}/#{slug}/"
        )
      end

      private_class_method :load_from_file

      # A plain-text name for the note, as notes rarely have titles: its title,
      # else its first ten words, else the first ten words of the Bluesky post or
      # Instagram caption it links to, else its link's title, else its date.
      def label
        return title unless title.empty?

        words = Nokogiri::HTML5.fragment(body_html).text.split
        words = (link&.bluesky&.text || (link.description if link&.instagram)).to_s.split if words.empty?
        return words.first(10).join(" ") + ((words.size > 10) ? "…" : "") if words.any?

        link&.title || "Note from #{date.strftime("%b %-d, %Y")}"
      end
    end
  end
end
