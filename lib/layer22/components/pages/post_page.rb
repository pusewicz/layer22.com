# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class PostPage < Base
        TAG_CLASS = "text-[12px] font-display font-medium tracking-[0.06em] uppercase text-[#6B6968] no-underline " \
          "border border-[#D4D0CB] rounded px-2 py-0.5 hover:text-[#0F0E0D] hover:border-[#9B9895]"

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
            article(class: "post h-entry w-full bg-[#F5F3F0]") do
              post_header
              div(class: "max-w-[1080px] mx-auto px-6 pt-8 post-body e-content") { raw safe(@post.body_html) }
              post_footer
            end
            script { raw safe(HEADER_LINKS_JS) }
          end
        end

        private

        def post_header
          div(class: "max-w-[1080px] mx-auto px-6 pt-12") do
            a(href: "/archive",
              class: "font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#C00000] no-underline " \
                     "hover:text-[#8A0000] mb-4 block") { "Writing" }
            h1(class: "p-name font-display text-[40px] font-bold tracking-[-0.02em] text-[#0F0E0D] leading-[1.15] m-0 " \
                      "max-w-[640px]") { @post.title }
            div(class: "flex items-center gap-2 mt-4 flex-wrap") do
              a(class: "p-author h-card text-[14px] text-[#7A7774] no-underline hover:text-[#0F0E0D]",
                href: absolute_url("/")) { config.author_name }
              separator
              a(class: "u-url no-underline", href: absolute_url(@post.permalink)) do
                time(class: "dt-published text-[14px] text-[#7A7774]", datetime: @post.date.xmlschema) do
                  format_date(@post.date)
                end
              end
              separator
              span(class: "text-[14px] text-[#7A7774]") { reading_time_label(@post.reading_time) }
              post_tags if @post.tags.any?
            end
          end
        end

        def post_tags
          separator
          div(class: "flex gap-1.5") do
            @post.tags.each { |tag| a(href: tag_url(tag), class: TAG_CLASS) { tag } }
          end
        end

        def separator
          span(class: "text-[14px] text-[#C8C4BE]") { "·" }
        end

        def post_footer
          div(class: "max-w-[1080px] mx-auto px-6 pt-8 pb-4") do
            div(class: "max-w-[640px]") do
              div(class: "w-full h-[1px] bg-[#D4D0CB] mb-3")
              div(class: "flex items-center justify-between") do
                span(class: "text-[13px] text-[#7A7774]") do
                  time(datetime: @post.last_modified_at.xmlschema) { "Last modified #{format_date(@post.last_modified_at)}" }
                end
                a(href: "#{config.github["repository_url"]}/edit/#{config.github["branch"]}/#{@post.relative_path}",
                  class: "text-[13px] text-[#C00000] underline hover:text-[#8A0000]") { "Edit on GitHub" }
              end
            end
          end
        end
      end
    end
  end
end
