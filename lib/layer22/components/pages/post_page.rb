# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class PostPage < Base
        def initialize(site:, post:)
          super(site:)
          @post = post
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            page_title: @post.title,
            url: @post.permalink,
            type: "article",
            extra_css: site.syntax_css
          ) do
            article(class: "max-w-[720px] mx-auto px-6 py-16 post") do
              hgroup(class: "mb-12") do
                h1(class: "text-[42px] md:text-[56px] font-black tracking-[-0.03em] text-[#0F0E0D] leading-[1.1] mb-6 font-display uppercase") do
                  @post.title
                end
                render Shared::PostMeta.new(site:, post: @post)
              end
              div(class: "prose-content") { raw safe(@post.body_html) }
              footer(class: "mt-12 pt-6 border-t border-[#C8C4BE] flex items-center justify-between text-[13px] text-[#6B6968]") do
                span do
                  plain "Last modified "
                  time(datetime: @post.last_modified_at.iso8601) do
                    format_date(@post.last_modified_at, "%B %-d, %Y")
                  end
                end
                a(href: "#{config.github["repository_url"]}/edit/#{config.github["branch"]}/#{@post.relative_path}",
                  class: "text-[#6B6968] hover:text-[#0F0E0D]",
                  title: "Edit this page on GitHub") { "Edit" }
              end
            end
            script do
              raw safe(<<~JS)
                const headings = document.querySelectorAll('article.post > h2[id], h3[id]');
                for (const heading of headings) {
                  const linkIcon = document.createElement('a');
                  linkIcon.setAttribute('href', `#${heading.id}`);
                  linkIcon.setAttribute('class', 'header-link');
                  linkIcon.setAttribute('title', `Link to the "${heading.innerText}" heading`);
                  heading.appendChild(linkIcon);
                }
              JS
            end
          end
        end
      end
    end
  end
end
