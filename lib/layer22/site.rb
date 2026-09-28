# frozen_string_literal: true

require "fileutils"

module Layer22
  class Site
    attr_reader :config, :posts, :tils, :pages, :css, :syntax_css

    def initialize(config_path: "site.yml")
      @config = Config.load(config_path)
    end

    def load_content(words_per_minute: nil)
      wpm = words_per_minute || @config.words_per_minute
      @posts = Content::Post.load_all("_posts", words_per_minute: wpm).sort_by(&:date)
      @tils = Content::TIL.load_all("_til").sort_by(&:date)
      @pages = Content::Page.load_all("_pages")
      self
    end

    def compile_css(tailwind: true)
      if tailwind
        Rendering::CSS.compile_tailwind
      end
      @css = Rendering::CSS.combined_css
      @syntax_css = Rendering::CSS.load_syntax
      self
    end

    def build(output_dir: "_site", skip_webp: false)
      FileUtils.mkdir_p(output_dir)

      load_content
      compile_css

      write_home(output_dir)
      write_posts(output_dir)
      write_tils(output_dir)
      write_pages(output_dir)
      write_404(output_dir)

      run_generators(output_dir, skip_webp:)
      copy_static_assets(output_dir)
      copy_redirects(output_dir)

      puts "Build complete → #{output_dir}"
      self
    end

    # Writes +content+ to the file that serves +url+ inside +output_dir+.
    def write_page(url, content, output_dir:)
      path = OutputPath.for(url, output_dir:)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
      puts "Generated #{path}"
    end

    private

    def write_home(output_dir)
      html = Components::Pages::HomePage.new(site: self).call
      write_page("/", html, output_dir:)
    end

    def write_posts(output_dir)
      @posts.each do |post|
        html = Components::Pages::PostPage.new(site: self, post:).call
        write_page(post.permalink, html, output_dir:)
      end
    end

    def write_tils(output_dir)
      sorted = @tils.sort_by(&:date)
      sorted.each_with_index do |til, i|
        prev_til = i > 0 ? sorted[i - 1] : nil
        next_til = sorted[i + 1]
        html = Components::Pages::TilPage.new(site: self, til:, prev_til:, next_til:).call
        write_page(til.permalink, html, output_dir:)
      end
    end

    def write_pages(output_dir)
      @pages.each do |page|
        next unless page.permalink
        html = Components::Pages::StaticPage.new(site: self, page:).call
        write_page(page.permalink, html, output_dir:)
      end
    end

    def write_404(output_dir)
      html = Components::Pages::NotFoundPage.new(site: self).call
      write_page("/404.html", html, output_dir:)
    end

    def run_generators(output_dir, skip_webp:)
      Generators::FeedGenerator.new(self).generate(output_dir:)
      Generators::SitemapGenerator.new(self).generate(output_dir:)
      Generators::ArchivesGenerator.new(self).generate(output_dir:)
      Generators::RedirectGenerator.new(self).generate(output_dir:)
      Generators::WebfingerGenerator.new(self).generate(output_dir:)
      Generators::RobotsGenerator.new(self).generate(output_dir:)
      Generators::WebpGenerator.new(self).generate(output_dir:) unless skip_webp
    end

    def copy_static_assets(output_dir)
      # Copy images directory
      if Dir.exist?("images")
        FileUtils.cp_r("images", output_dir)
        puts "Copied images/"
      end

      # Copy favicon files
      %w[favicon.ico favicon.svg favicon-16x16.png favicon-32x32.png
         apple-touch-icon.png android-chrome-192x192.png android-chrome-512x512.png
         site.webmanifest].each do |file|
        FileUtils.cp(file, output_dir) if File.exist?(file)
      end
      puts "Copied static assets"
    end

    def copy_redirects(output_dir)
      FileUtils.cp("_redirects", output_dir) if File.exist?("_redirects")
      puts "Copied _redirects"
    end
  end
end
