# frozen_string_literal: true

require "fastimage"

module Layer22
  module Content
    # The link a note points at, with the preview metadata `rake note` saved:
    # site, title, author, description and a local thumbnail, or for a YouTube
    # video its id.
    Link = Data.define(:url, :site, :youtube, :title, :author, :description, :image, :image_width, :image_height) do
      # Builds a link from a note's `link` front matter; nil when there is none.
      # Image dimensions are read from the thumbnail under +root+, if present.
      def self.from_front_matter(data, root: ".")
        return if data.nil?

        image = data["image"]
        width, height = FastImage.size(File.join(root, image.delete_prefix("/"))) if image
        new(
          url: data.fetch("url"),
          site: data["site"],
          youtube: data["youtube"],
          title: data["title"],
          author: data["author"],
          description: data["description"],
          image:,
          image_width: width,
          image_height: height
        )
      end

      # The URL's host without a leading "www.", shown when the site name is unknown.
      def host
        url.split("/")[2].to_s.delete_prefix("www.")
      end

      # Whether the thumbnail is wider than 5:4, and so shown full width above the text.
      def wide_image?
        image_width && image_height&.positive? && image_width * 4 > image_height * 5
      end
    end
  end
end
