# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class TagPage < Base
        def initialize(site:, tag:, posts:)
          super(site:)
          @tag = tag
          @posts = posts
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            page_title: "Posts tagged: #{@tag}",
            url: "/tags/#{@tag}/"
          ) do
            div(class: "max-w-[1080px] mx-auto px-6 py-16") do
              div(class: "mb-12") do
                p(class: "text-[13px] font-medium tracking-[0.12em] uppercase text-[#6B6968] mb-3 font-display") { "Tag" }
                h1(class: "text-[48px] font-black tracking-[-0.03em] uppercase text-[#0F0E0D] leading-none font-display") do
                  @tag
                end
              end
              div do
                @posts.sort_by(&:date).reverse.each do |post|
                  render Shared::PostListItem.new(site:, post:)
                end
                div(class: "border-b border-[#C8C4BE]")
              end
            end
          end
        end
      end
    end
  end
end
