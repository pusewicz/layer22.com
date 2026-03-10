# frozen_string_literal: true

module Layer22
  module Generators
    class WebpGenerator
      FORMATS = %w[.jpeg .jpg .png .tiff].freeze

      def initialize(site)
        @site = site
        @config = site.config
      end

      def generate(output_dir: "_site")
        img_dirs = @config.webp["img_dirs"] || ["images"]
        quality = @config.webp["quality"] || 75

        img_dirs.each do |dir|
          source_dir = dir.sub(%r{^/}, "")
          dest_dir = File.join(output_dir, dir.sub(%r{^/}, ""))

          next unless Dir.exist?(source_dir)

          Dir.glob("#{source_dir}/**/*").each do |path|
            next unless FORMATS.include?(File.extname(path).downcase)

            relative = path.sub("#{source_dir}/", "")
            dest_path = File.join(dest_dir, File.dirname(relative),
                                  "#{File.basename(relative, ".*")}.webp")

            next if File.exist?(dest_path)

            FileUtils.mkdir_p(File.dirname(dest_path))
            case system("cwebp", "-quiet", "-q", quality.to_s, path, "-o", dest_path, err: File::NULL)
            when true then puts "WebP: #{path} → #{dest_path}"
            when false then warn "WebP: cwebp could not convert #{path}"
            else
              warn "WebP: cwebp not found, skipping WebP conversion"
              return
            end
          end
        end
      end
    end
  end
end
