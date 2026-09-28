# frozen_string_literal: true

module Layer22
  module Content
    Post = Data.define(
      :title,
      :slug,
      :date,
      :tags,
      :body_html,
      :word_count,
      :reading_time,
      :redirect_from,
      :meta_keywords,
      :last_modified_at,
      :relative_path,
      :permalink
    ) do
      def self.load_all(dir = "_posts", words_per_minute: 180.0)
        paths = Dir.glob("#{dir}/**/*.{md,markdown}").sort
        paths.map { |path| load_from_file(path, words_per_minute:) }
      end

      def self.load_from_file(path, words_per_minute: 180.0)
        content = File.read(path, encoding: "UTF-8")
        front_matter, body = FrontMatter.parse(content)

        body_html = Rendering::Markdown.render(body)
        words = body.split.size
        reading_time = (words / words_per_minute).ceil

        slug = front_matter["slug"] || File.basename(path, ".*").gsub(/^\d{4}-\d{2}-\d{2}-/, "")
        date = Timestamp.parse(front_matter["date"] || File.basename(path)[/\A\d{4}-\d{2}-\d{2}/], source: path)

        new(
          title: front_matter["title"] || slug,
          slug: slug,
          date: date,
          tags: Array(front_matter["tags"]),
          body_html: body_html,
          word_count: words,
          reading_time: reading_time,
          redirect_from: Array(front_matter["redirect_from"]),
          meta_keywords: front_matter["meta_keywords"],
          last_modified_at: Timestamp.parse(front_matter["last_modified_at"], source: path) || date,
          relative_path: path,
          permalink: "/#{slug}"
        )
      end

      private_class_method :load_from_file

      def url
        permalink
      end

      def formatted_date(fmt = "%B %-d, %Y")
        date.strftime(fmt)
      end
    end
  end
end
