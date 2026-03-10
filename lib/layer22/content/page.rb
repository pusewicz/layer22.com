# frozen_string_literal: true

module Layer22
  module Content
    Page = Data.define(
      :title,
      :permalink,
      :body_html,
      :redirect_to,
      :layout,
      :relative_path
    ) do
      def self.load_all(dir = "_pages")
        paths = Dir.glob("#{dir}/**/*.{md,markdown,html}").sort
        pages = paths.filter_map { |path| load_from_file(path) }
        pages.select { |p| p.permalink }
      end

      def self.load_from_file(path)
        content = File.read(path, encoding: "UTF-8")
        front_matter, body = FrontMatter.parse(content)

        # Skip HTML pages containing Liquid template syntax — handled by generators
        return nil if path.end_with?(".html") && body.match?(/\{[%{]/)

        body_html = if path.end_with?(".html")
          body
        else
          Rendering::Markdown.render(body)
        end

        new(
          title: front_matter["title"],
          permalink: front_matter["permalink"],
          body_html: body_html,
          redirect_to: front_matter["redirect_to"],
          layout: front_matter["layout"] || "page",
          relative_path: path
        )
      end

      private_class_method :load_from_file

      def url
        permalink
      end
    end
  end
end
