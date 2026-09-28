# frozen_string_literal: true

require "fileutils"

module Layer22
  class Site
    STATIC_FILES = %w[
      favicon.ico favicon.svg favicon-16x16.png favicon-32x32.png
      apple-touch-icon.png android-chrome-192x192.png android-chrome-512x512.png
      site.webmanifest piotr-usewicz-resume.pdf
    ].freeze
    STATIC_DIRS = %w[images assets/fonts].freeze

    attr_reader :config, :posts, :tils, :pages, :data, :css, :syntax_css

    # Loads the site config and, like Jekyll, makes its timezone the process-wide
    # local zone so every date renders in it.
    def initialize(config_path: "site.yml")
      @config = Config.load(config_path)
      ENV["TZ"] = @config.timezone
    end

    def load_content(words_per_minute: nil)
      wpm = words_per_minute || @config.words_per_minute
      @posts = Content::Post.load_all("_posts", words_per_minute: wpm).sort_by(&:date)
      @tils = Content::TIL.load_all("_til", words_per_minute: wpm).sort_by(&:date)
      @pages = Content::Page.load_all("_pages")
      @data = Content::DataFiles.load_all("_data")
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

      routes.each { |url, render| write_page(url, render.call, output_dir:) }
      run_generators(output_dir, skip_webp:)
      copy_static_assets(output_dir)
      copy_redirects(output_dir)

      puts "Build complete → #{output_dir}"
      self
    end

    # Returns every HTML page of the site as {url => renderer}, where calling
    # the renderer returns the page. The build writes them all; the dev server
    # renders the one requested.
    def routes
      routes = {}
      add = lambda do |url, render|
        raise ArgumentError, "two pages claim #{url}" if routes.key?(url)

        routes[url] = render
      end

      add.call("/", -> { Components::Pages::HomePage.new(site: self).call })
      @posts.each { |post| add.call(post.permalink, -> { Components::Pages::PostPage.new(site: self, post:).call }) }
      @tils.each_with_index do |til, i|
        prev_til = @tils[i - 1] if i > 0
        next_til = @tils[i + 1]
        add.call(til.permalink, -> { Components::Pages::TilPage.new(site: self, til:, prev_til:, next_til:).call })
      end
      @pages.each { |page| add.call(page.permalink, -> { render_page(page) }) }
      add.call("/404.html", -> { Components::Pages::NotFoundPage.new(site: self).call })
      Generators::ArchivesGenerator.new(self).archives.each { |archive| add.call(archive.url, -> { archive.page.call }) }
      @posts.each do |post|
        target = "#{config.site_url}#{post.permalink}"
        post.redirect_from.each { |from| add.call(from, -> { Components::Pages::RedirectPage.new(to: target).call }) }
      end
      routes
    end

    # Writes +content+ to the file that serves +url+ inside +output_dir+.
    def write_page(url, content, output_dir:)
      path = OutputPath.for(url, output_dir:)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
      puts "Generated #{path}"
    end

    # Posts grouped by tag, like Jekyll's site.tags: tags in order of first use,
    # each tag's posts newest first.
    def tags
      group_posts(&:tags)
    end

    # Posts grouped by category, ordered like #tags.
    def categories
      group_posts(&:categories)
    end

    private

    # Returns the HTML for a page from _pages/, rendered with the component for
    # its layout, or a redirect when it sets redirect_to.
    def render_page(page)
      return Components::Pages::RedirectPage.new(to: page.redirect_to).call if page.redirect_to

      case page.layout
      when "page" then Components::Pages::StaticPage.new(site: self, page:).call
      when "archive" then Components::Pages::ArchivePage.new(site: self, page:).call
      when "resume" then Components::Pages::ResumePage.new(site: self, page:).call
      when "resume_print" then Components::Pages::ResumePrintPage.new(resume: data.fetch("resume")).call
      else raise ArgumentError, "#{page.relative_path}: unknown layout #{page.layout.inspect}"
      end
    end

    def group_posts
      groups = Hash.new { |hash, name| hash[name] = [] }
      @posts.each { |post| yield(post).each { |name| groups[name] << post } }
      groups.transform_values(&:reverse)
    end

    def run_generators(output_dir, skip_webp:)
      Generators::FeedGenerator.new(self).generate(output_dir:)
      Generators::SitemapGenerator.new(self).generate(output_dir:)
      Generators::WebfingerGenerator.new(self).generate(output_dir:)
      Generators::RobotsGenerator.new(self).generate(output_dir:)
      Generators::WebpGenerator.new(self).generate(output_dir:) unless skip_webp
    end

    def copy_static_assets(output_dir)
      STATIC_DIRS.each do |dir|
        next unless Dir.exist?(dir)

        FileUtils.mkdir_p(File.join(output_dir, File.dirname(dir)))
        FileUtils.cp_r(dir, File.join(output_dir, File.dirname(dir)))
        puts "Copied #{dir}/"
      end

      STATIC_FILES.each do |file|
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
