# frozen_string_literal: true

require "commonmarker"
require "rouge"
require "cgi"

module Layer22
  module Rendering
    module Markdown
      def self.render(text)
        # Disable commonmarker's built-in highlighting; we use Rouge
        html = Commonmarker.to_html(text, options: { render: { unsafe: true } }, plugins: { syntax_highlighter: nil })
        highlight_code_blocks(html)
      end

      def self.highlight_code_blocks(html)
        html.gsub(/<pre lang="([^"]+)"><code>(.*?)<\/code><\/pre>/m) do
          lang = ::Regexp.last_match(1)
          code = CGI.unescapeHTML(::Regexp.last_match(2))
          highlighted = highlight(code, lang)
          %(<div class="highlight"><pre class="highlight #{lang}">#{highlighted}</pre></div>)
        end
      end

      def self.highlight(code, lang)
        lexer = Rouge::Lexer.find(lang) || Rouge::Lexers::PlainText
        formatter = Rouge::Formatters::HTML.new
        formatter.format(lexer.lex(code))
      end

      private_class_method :highlight_code_blocks, :highlight
    end
  end
end
