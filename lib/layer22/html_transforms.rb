# frozen_string_literal: true

require "nokogiri"
require "fastimage"

module Layer22
  module HtmlTransforms
    def self.apply(html, base_dir: ".")
      doc = Nokogiri::HTML5.fragment(html)
      add_image_dimensions(doc, base_dir:)
      add_lazy_loading(doc)
      doc.to_html
    end

    def self.add_image_dimensions(doc, base_dir:)
      doc.css("img").each do |img|
        src = img["src"]
        next if img["width"] || img["height"] || src.nil? || src.start_with?("http", "//", "data:")

        path = File.join(base_dir, src.sub(%r{^/}, ""))
        next unless File.exist?(path)

        size = FastImage.size(path)
        next unless size

        img["width"] = size[0].to_s
        img["height"] = size[1].to_s
      end
    end

    def self.add_lazy_loading(doc)
      doc.css("img").each do |img|
        img["loading"] = "lazy" unless img["loading"]
      end
    end

    private_class_method :add_image_dimensions, :add_lazy_loading
  end
end
