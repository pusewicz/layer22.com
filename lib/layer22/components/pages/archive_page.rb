# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      class ArchivePage < Base
        def initialize(site:, title:, posts:, url:)
          super(site:)
          @title = title
          @posts = posts
          @url = url
        end

        def view_template
          render Layouts::ApplicationLayout.new(site:, page_title: @title, url: @url) do
            div(class: "max-w-[1080px] mx-auto px-6 py-16") do
              div(class: "mb-12") do
                h1(class: "text-[48px] font-black tracking-[-0.03em] uppercase text-[#0F0E0D] leading-none font-display") do
                  @title
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
