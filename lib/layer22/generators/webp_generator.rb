# frozen_string_literal: true

module Layer22
  module Generators
    # Converts the images in the configured directories to WebP with cwebp,
    # skipping any that already have a WebP file in the output.
    class WebpGenerator
      FORMATS = %w[.jpeg .jpg .png .tiff].freeze

      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        quality = @config.webp["quality"] || 75

        conversions(output_dir).each do |path, dest_path|
          next if File.exist?(dest_path)

          FileUtils.mkdir_p(File.dirname(dest_path))
          case system("cwebp", "-quiet", "-q", quality.to_s, path, "-o", dest_path, err: File::NULL)
          when true then puts "WebP: #{path} → #{dest_path}"
          when false then warn "WebP: cwebp could not convert #{path}"
          else
            warn "WebP: cwebp not found, skipping WebP conversion"
            break
          end
        end
      end

      private

      # Returns [source, destination] for every convertible image, in order.
      def conversions(output_dir)
        (@config.webp["img_dirs"] || ["images"]).flat_map do |dir|
          source_dir = dir.sub(%r{^/}, "")
          next [] unless Dir.exist?(source_dir)

          Dir.glob("#{source_dir}/**/*").filter_map do |path|
            next unless FORMATS.include?(File.extname(path).downcase)

            [path, File.join(output_dir, "#{path.delete_suffix(File.extname(path))}.webp")]
          end
        end
      end
    end
  end
end
