# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class TagsIndexPage < Base
        def initialize(site:, tags:)
          super(site:)
          @tags = tags
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            page_title: "All Tags",
            url: "/tags"
          ) do
            div(class: "max-w-[1080px] mx-auto px-6 py-16") do
              div(class: "mb-12") do
                h1(class: "text-[48px] font-black tracking-[-0.03em] uppercase text-[#0F0E0D] leading-none font-display") do
                  "Archive by Tag"
                end
              end
              div(class: "flex flex-wrap gap-4") do
                @tags.each do |tag, posts|
                  slug = tag.downcase.gsub(/\s+/, "-")
                  a(href: "/tags/#{slug}/",
                    class: "inline-flex items-center gap-2 font-display text-[14px] tracking-widest uppercase text-[#6B6968] hover:text-[#0F0E0D] no-underline") do
                    plain tag
                    span(class: "text-[11px] text-[#C8C4BE]") { "(#{posts.size})" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
