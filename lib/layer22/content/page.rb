# frozen_string_literal: true

module Layer22
  module Content
    Page = Data.define(
      :title,
      :permalink,
      :body_html,
      :redirect_to,
      :layout,
      :description,
      :sitemap,
      :front_matter,
      :last_modified_at,
      :relative_path
    ) do
      def self.load_all(dir = "_pages")
        paths = Dir.glob("#{dir}/**/*.{md,markdown,html}").sort
        paths.map { |path| load_from_file(path) }.select(&:permalink)
      end

      def self.load_from_file(path)
        content = File.read(path, encoding: "UTF-8")
        front_matter, body = FrontMatter.parse(content)

        body_html = if path.end_with?(".html")
          body
        else
          Rendering::Markdown.render(body)
        end

        new(
          title: FrontMatter.text(front_matter["title"]),
          permalink: front_matter["permalink"],
          body_html: body_html,
          redirect_to: front_matter["redirect_to"],
          layout: front_matter["layout"] || "page",
          description: front_matter["description"],
          sitemap: front_matter.fetch("sitemap", true),
          front_matter: front_matter,
          last_modified_at: LastModified.for(path),
          relative_path: path
        )
      end

      private_class_method :load_from_file
    end
  end
end
