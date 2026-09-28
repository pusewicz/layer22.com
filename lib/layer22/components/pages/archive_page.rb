# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # The "Writing" archive: every post, newest first, grouped by year.
      class ArchivePage < Base
        def initialize(site:, page:)
          super(site:)
          @page = page
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "archive",
            title: @page.title,
            seo: {url: @page.permalink, description: @page.description, modified_at: @page.last_modified_at}
          ) do
            div(class: "w-full bg-[#F5F3F0]") do
              div(class: "h-feed max-w-[1080px] mx-auto px-6 pt-12 pb-8") do
                h1(class: "p-name font-display text-[40px] font-bold tracking-[-0.02em] text-[#0F0E0D] leading-[1.15] m-0") do
                  "Writing"
                end
                site.posts.reverse.group_by { |post| post.date.year }.each { |year, posts| year_section(year, posts) }
              end
            end
          end
        end

        private

        def year_section(year, posts)
          div(class: "mt-8") do
            h2(class: "font-display text-[22px] font-semibold tracking-[0.02em] text-[#9B9895] leading-none m-0 mb-2") do
              year.to_s
            end
            posts.each do |post|
              div(class: "h-entry flex items-baseline justify-between py-[10px] border-b border-[#E2DFDB]") do
                a(href: absolute_url(post.permalink),
                  class: "p-name u-url text-[17px] text-[#0F0E0D] no-underline hover:text-[#C00000] leading-6") { post.title }
                time(class: "dt-published font-display text-[13px] tracking-[0.06em] uppercase text-[#9B9895] shrink-0 ml-10",
                     datetime: post.date.xmlschema) { format_date(post.date, "%b %Y") }
              end
            end
          end
        end
      end
    end
  end
end
