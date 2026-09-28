# frozen_string_literal: true

module Layer22
  # Maps site URLs to files in the output directory the same way Jekyll does, so
  # Cloudflare Pages serves every URL without a trailing-slash redirect.
  module OutputPath
    # Returns the path of the file that serves +url+ inside +output_dir+.
    #
    #   OutputPath.for("/about", output_dir: "_site")     # => "_site/about.html"
    #   OutputPath.for("/2015/", output_dir: "_site")     # => "_site/2015/index.html"
    #   OutputPath.for("/404.html", output_dir: "_site")  # => "_site/404.html"
    def self.for(url, output_dir:)
      relative = if url.end_with?("/")
        "#{url}index.html"
      elsif File.extname(url).empty?
        "#{url}.html"
      else
        url
      end
      File.join(output_dir, relative)
    end
  end
end
