module Middleman
  module Syntax
    module RedcarpetCodeRenderer
      def block_code(code, language)
        %{<pre><code class="#{language}">#{code}</code></pre>}
      end
    end

    class SyntaxExtension < Extension
      def after_configuration
        ::Middleman::Renderers::MiddlemanRedcarpetHTML.send :include, RedcarpetCodeRenderer
      end
    end
  end
end

::Middleman::Extensions.register(:syntax, Middleman::Syntax::SyntaxExtension)
