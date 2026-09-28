# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class PostPage < Base
        # Adds a hover anchor to every linkable heading of the post. The anchor
        # shows only a CSS icon, so its label names it for screen readers.
        HEADER_LINKS_JS = <<~JS
          const headings = document.querySelectorAll('article.post h2[id], article.post h3[id]');
          for (const heading of headings) {
            const label = `Link to the "${heading.innerText}" heading`;
            const linkIcon = document.createElement('a');
            linkIcon.setAttribute('href', `#${heading.id}`);
            linkIcon.setAttribute('class', `header-link`);
            linkIcon.setAttribute('title', label);
            linkIcon.setAttribute('aria-label', label);
            heading.appendChild(linkIcon);
          }
        JS

        def initialize(site:, post:)
          super(site:)
          @post = post
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "post",
            title: @post.title,
            seo: {
              kind: :article,
              url: @post.permalink,
              description: @post.description,
              published_at: @post.date,
              modified_at: @post.last_modified_at
            },
            extra_css: site.syntax_css
          ) do
            article(class: "post h-entry") do
              post_header
              div(class: "site-width post-body e-content") { raw safe(@post.body_html) }
              post_footer
            end
            script { raw safe(HEADER_LINKS_JS) }
          end
        end

        private

        def post_header
          div(class: "site-width post-header") do
            a(href: "/archive", class: "section-kicker") { "Writing" }
            h1(class: "p-name page-title reading-width") { @post.title }
            div(class: "post-byline") do
              a(class: "p-author h-card post-author", href: absolute_url("/")) { config.author_name }
              separator
              a(class: "u-url post-permalink", href: absolute_url(@post.permalink)) do
                time(class: "dt-published post-byline-text", datetime: @post.date.xmlschema) { format_date(@post.date) }
              end
              separator
              span(class: "post-byline-text") { reading_time_label(@post.reading_time) }
              post_tags if @post.tags.any?
            end
          end
        end

        def post_tags
          separator
          div(class: "post-tags") do
            @post.tags.each { |tag| a(href: tag_url(tag), class: "post-tag") { tag } }
          end
        end

        def separator
          span(class: "post-byline-separator") { "·" }
        end

        def post_footer
          div(class: "site-width post-footer") do
            div(class: "reading-width") do
              div(class: "post-footer-rule")
              div(class: "post-footer-row") do
                span(class: "post-modified") do
                  time(datetime: @post.last_modified_at.xmlschema) { "Last modified #{format_date(@post.date)}" }
                end
                a(href: "#{config.github["repository_url"]}/edit/#{config.github["branch"]}/#{@post.relative_path}") do
                  "Edit on GitHub"
                end
              end
            end
          end
        end
      end
    end
  end
end
