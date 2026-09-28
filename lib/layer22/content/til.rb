# frozen_string_literal: true

module Layer22
  module Content
    TIL = Data.define(
      :title,
      :slug,
      :date,
      :tags,
      :categories,
      :description,
      :body_html,
      :word_count,
      :reading_time,
      :last_modified_at,
      :relative_path,
      :permalink
    ) do
      def self.load_all(dir = "_til", words_per_minute: 180.0)
        paths = Dir.glob("#{dir}/**/*.{md,markdown}").sort
        paths.map { |path| load_from_file(path, words_per_minute:) }
      end

      def self.load_from_file(path, words_per_minute:)
        content = File.read(path, encoding: "UTF-8")
        front_matter, body = FrontMatter.parse(content)

        body_html = Rendering::Markdown.render(body)
        words = Rendering::WordCount.count(body_html)
        filename = File.basename(path, ".*")
        date = Timestamp.parse(front_matter["date"] || filename[/\A\d{4}-\d{2}-\d{2}/], source: path) || Time.now

        slug = filename.gsub(/^\d{4}-\d{2}-\d{2}-/, "")
        year = date.strftime("%Y")
        month = date.strftime("%m")
        day = date.strftime("%d")

        new(
          title: FrontMatter.text(front_matter["title"]) || slug,
          slug: slug,
          date: date,
          tags: FrontMatter.list(front_matter, "tag", "tags"),
          categories: FrontMatter.list(front_matter, "category", "categories"),
          description: front_matter["description"] || Rendering::Excerpt.from_markdown(body),
          body_html: body_html,
          word_count: words,
          reading_time: (words / words_per_minute).ceil,
          last_modified_at: Timestamp.parse(front_matter["last_modified_at"], source: path) || LastModified.for(path),
          relative_path: path,
          permalink: "/til/#{year}/#{month}/#{day}/#{slug}/"
        )
      end

      private_class_method :load_from_file
    end
  end
end
