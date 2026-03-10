# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class PostMeta < Base
        def initialize(site:, post:, show_tags: true)
          super(site:)
          @post = post
          @show_tags = show_tags
        end

        def view_template
          div(class: "flex flex-wrap items-center gap-4 text-[13px] text-[#6B6968] font-display tracking-[0.04em]") do
            time(datetime: @post.date.iso8601, class: "uppercase") do
              format_date(@post.date, "%B %-d, %Y")
            end
            if @post.respond_to?(:reading_time) && @post.reading_time
              span { "·" }
              span { reading_time_label(@post.reading_time) }
            end
            if @show_tags && @post.tags.any?
              span { "·" }
              div(class: "flex flex-wrap gap-2") do
                @post.tags.each do |tag|
                  a(href: tag_url(tag),
                    class: "text-[#6B6968] hover:text-[#0F0E0D] no-underline uppercase tracking-widest text-[11px]") { tag }
                end
              end
            end
          end
        end
      end
    end
  end
end
