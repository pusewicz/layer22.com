# frozen_string_literal: true

module Layer22
  module Rendering
    module CSS
      def self.compile_tailwind(input: "styles/tailwind.input.css", output: "tmp/tailwind.css")
        FileUtils.mkdir_p("tmp")
        system("bunx tailwindcss -i #{input} -o #{output} --minify", exception: true)
      end

      def self.load_base
        [File.read("styles/normalize.css"), File.read("styles/base.css")].join("\n")
      end

      def self.load_tailwind(path: "tmp/tailwind.css")
        File.exist?(path) ? File.read(path) : ""
      end

      def self.load_syntax
        File.read("styles/syntax.css")
      end

      def self.combined_css
        [load_base, load_tailwind].join("\n")
      end
    end
  end
end
