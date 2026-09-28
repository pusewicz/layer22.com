# frozen_string_literal: true

module Layer22
  module Content
    TIL = Data.define(
      :title,
      :slug,
      :date,
      :tags,
      :body_html,
      :relative_path,
      :permalink
    ) do
      def self.load_all(dir = "_til", words_per_minute: 180.0)
        paths = Dir.glob("#{dir}/**/*.{md,markdown}").sort
        paths.map { |path| load_from_file(path) }
      end

      def self.load_from_file(path)
        content = File.read(path, encoding: "UTF-8")
        front_matter, body = FrontMatter.parse(content)

        body_html = Rendering::Markdown.render(body)
        filename = File.basename(path, ".*")
        date = Timestamp.parse(front_matter["date"] || filename[/\A\d{4}-\d{2}-\d{2}/], source: path) || Time.now

        slug = filename.gsub(/^\d{4}-\d{2}-\d{2}-/, "")
        year = date.strftime("%Y")
        month = date.strftime("%m")
        day = date.strftime("%d")

        new(
          title: front_matter["title"] || slug,
          slug: slug,
          date: date,
          tags: Array(front_matter["tags"]),
          body_html: body_html,
          relative_path: path,
          permalink: "/til/#{year}/#{month}/#{day}/#{slug}/"
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
