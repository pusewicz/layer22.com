# frozen_string_literal: true

require "commonmarker"
require "nokogiri"
require "rouge"

module Layer22
  module Rendering
    # Renders Markdown to the same HTML the Jekyll site produced with kramdown and
    # Rouge, so the site's styles and scripts keep working on it.
    module Markdown
      OPTIONS = {
        parse: {smart: true},
        render: {unsafe: true, github_pre_lang: false, hardbreaks: false},
        extension: {header_ids: nil, tagfilter: false, autolink: false}
      }.freeze

      # Returns +text+ rendered to HTML.
      def self.render(text)
        html = Commonmarker.to_html(text.encode(Encoding::UTF_8), options: OPTIONS, plugins: {syntax_highlighter: nil})
        fragment = Nokogiri::HTML5.fragment(html)
        highlight_code_blocks(fragment)
        mark_inline_code(fragment)
        add_heading_ids(fragment)
        add_lazy_loading(fragment)
        fragment.to_html
      end

      # Wraps fenced and indented code in kramdown's Rouge markup; code in a
      # language Rouge does not know stays a plain <pre><code>, as with kramdown.
      def self.highlight_code_blocks(fragment)
        fragment.css("pre > code").each do |code|
          language = code["class"].to_s[/\blanguage-(\S+)/, 1] || "plaintext"
          lexer = Rouge::Lexer.find(language)
          next unless lexer

          highlighted = Rouge::Formatters::HTML.new.format(lexer.lex(code.text))
          code.parent.replace(<<~HTML.chomp)
            <div class="language-#{language} highlighter-rouge"><div class="highlight"><pre class="highlight"><code>#{highlighted}</code></pre></div></div>
          HTML
        end
      end

      # Marks inline code spans the way kramdown does with Rouge as its highlighter.
      def self.mark_inline_code(fragment)
        fragment.css("code").each do |code|
          next if code.ancestors("pre").any?

          code["class"] = "language-plaintext highlighter-rouge"
        end
      end

      # Gives every heading kramdown's auto-generated id, which in-page links use.
      def self.add_heading_ids(fragment)
        used = Hash.new(0)
        fragment.css("h1, h2, h3, h4, h5, h6").each do |heading|
          next if heading["id"]

          base = heading.text.sub(/\A[^a-zA-Z]+/, "").tr("^a-zA-Z0-9 -", "").tr(" ", "-").downcase
          base = "section" if base.empty?
          heading["id"] = used[base].zero? ? base : "#{base}-#{used[base]}"
          used[base] += 1
        end
      end

      # Defers offscreen images, like the jekyll-loading-lazy plugin did.
      def self.add_lazy_loading(fragment)
        fragment.css("img:not([loading])").each { |img| img["loading"] = "lazy" }
      end

      private_class_method :highlight_code_blocks, :mark_inline_code, :add_heading_ids, :add_lazy_loading
    end
  end
end
