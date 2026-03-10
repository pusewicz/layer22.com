# frozen_string_literal: true

require "date"

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
        date = parse_date(front_matter["date"]) || parse_date_from_filename(filename)

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

      def self.parse_date(value)
        case value
        when Date, Time then value.to_date
        when String then Date.parse(value) rescue nil
        end
      end

      def self.parse_date_from_filename(filename)
        match = filename.match(/^(\d{4}-\d{2}-\d{2})/)
        match ? Date.parse(match[1]) : Date.today
      end

      private_class_method :load_from_file, :parse_date, :parse_date_from_filename

      def url
        permalink
      end

      def formatted_date(fmt = "%B %-d, %Y")
        date.strftime(fmt)
      end
    end
  end
end
