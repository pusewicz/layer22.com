# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class HomePage < Base
        def view_template
          render Layouts::ApplicationLayout.new(site:) do
            hero_section
            services_section
            about_section
            recent_posts_section
            cta_section
          end
        end

        private

        def hero_section
          section(class: "w-full bg-[#F5F3F0] py-[120px]") do
            div(class: "max-w-[1080px] mx-auto px-6 font-display") do
              p(class: "text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-6") { "Web Application Developer" }
              h1(class: "font-black uppercase text-[#0F0E0D] tracking-[-0.03em] leading-none mb-0") do
                span(class: "block text-[96px]") { "Piotr" }
                span(class: "block text-[96px]") { "Usewicz" }
              end
              div(class: "w-[120px] h-[3px] bg-[#C00000] my-10")
              p(class: "text-[28px] font-light tracking-[0.01em] leading-[140%] max-w-[640px] text-[#0F0E0D] m-0") do
                "Building functional web applications with Ruby, Rails, and modern JavaScript. Based in Benicàrlo, Spain."
              end
            end
          end
        end

        def services_section
          section(class: "w-full bg-[#ECEAE6] py-[120px]") do
            div(class: "max-w-[1080px] mx-auto px-6 font-display") do
              div(class: "mb-16") do
                p(class: "text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-4") { "What I Do" }
                h2(class: "text-[48px] font-bold tracking-[-0.02em] uppercase text-[#0F0E0D] leading-none m-0") { "Craft & Capability" }
              end
              div(class: "grid grid-cols-1 md:grid-cols-3 gap-12") do
                service_card("Backend",
                  "Ruby on Rails applications built for longevity — clean architecture, fast queries, and APIs that other services can rely on. Fifteen years of production experience.")
                service_card("Frontend",
                  "Hotwire, Stimulus, and vanilla JS for reactive interfaces without the framework weight. HTML and CSS with care for performance, accessibility, and craft.")
                service_card("Full Stack",
                  "End-to-end ownership from database schema to deployed interface. Comfortable with the full lifecycle: architecture, implementation, ops, and iteration.")
              end
            end
          end
        end

        def service_card(title, description)
          div do
            h3(class: "text-[22px] font-bold tracking-[0.06em] uppercase text-[#0F0E0D] mb-4 leading-7") { title }
            div(class: "w-full h-px bg-[#C8C4BE] mb-6")
            p(class: "text-[18px] tracking-[0.01em] leading-[160%] text-[#6B6968] m-0") { description }
          end
        end

        def about_section
          section(class: "w-full bg-[#F5F3F0] py-[120px]") do
            div(class: "max-w-[1080px] mx-auto px-6 font-display flex gap-20 items-start") do
              div(class: "grow shrink basis-0") do
                p(class: "text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-4") { "About" }
                h2(class: "text-[48px] font-bold tracking-[-0.02em] uppercase text-[#0F0E0D] leading-none mb-10") do
                  plain "Two Decades"
                  br
                  plain "of Code"
                end
                p(class: "text-[18px] tracking-[0.01em] leading-[170%] text-[#6B6968] mt-0 mb-6 mx-0") do
                  "I've been writing software professionally since 2005 — first in PHP, then Rails from the very early days. Over the years I've built SaaS products, internal tooling, developer APIs, and consumer applications, usually as the person who owns the whole stack."
                end
                p(class: "text-[18px] tracking-[0.01em] leading-[170%] text-[#6B6968] m-0") do
                  "Today I work independently — consulting, contracting, and building products of my own. I care about readable code, sensible defaults, and software that stays maintainable long after the initial excitement fades."
                end
              end
              div(class: "shrink-0 w-[320px]") do
                img(
                  src: "https://www.gravatar.com/avatar/dcbf676f860477e44b275cae5d6318a4.jpg?s=640",
                  alt: "Piotr Usewicz",
                  class: "w-[320px] h-[400px] object-cover",
                  loading: "lazy"
                )
              end
            end
          end
        end

        def recent_posts_section
          section(class: "w-full bg-[#ECEAE6] py-[120px]") do
            div(class: "max-w-[1080px] mx-auto px-6 font-display") do
              div(class: "flex items-end justify-between mb-14") do
                div do
                  p(class: "text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-4") { "Recent Writing" }
                  h2(class: "text-[48px] font-bold tracking-[-0.02em] uppercase text-[#0F0E0D] leading-none m-0") { "From the Blog" }
                end
                a(href: "/archive",
                  class: "font-display text-[14px] font-medium tracking-widest uppercase text-[#0F0E0D] no-underline underline decoration-1 pb-1.5 hover:text-[#6B6968]") { "View Archive" }
              end
              div do
                site.posts.last(3).reverse.each do |post|
                  render Shared::PostListItem.new(site:, post:)
                end
                div(class: "border-b border-[#C8C4BE]")
              end
            end
          end
        end

        def cta_section
          section(class: "w-full bg-[#F5F3F0] py-[140px] flex flex-col items-center") do
            div(class: "font-display text-center px-6") do
              h2(class: "text-[72px] font-black tracking-[-0.03em] uppercase text-[#0F0E0D] leading-none mb-8") do
                plain "Let's Build"
                br
                plain "Something"
              end
              p(class: "text-[22px] font-light tracking-[0.01em] leading-[150%] max-w-[500px] text-[#6B6968] mt-0 mb-12 mx-auto") do
                "Open to consulting engagements, contract work, and interesting conversations about hard problems."
              end
              a(href: "/contact",
                class: "inline-flex items-center justify-center py-[18px] px-12 bg-[#C00000] text-[16px] font-bold tracking-[0.12em] uppercase text-[#E8E6E3] no-underline hover:opacity-90") { "Get in Touch" }
            end
          end
        end
      end
    end
  end
end
