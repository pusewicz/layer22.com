# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      class PostListItem < Base
        def initialize(site:, post:)
          super(site:)
          @post = post
        end

        def view_template
          div(class: "flex items-baseline justify-between py-7 border-t border-[#C8C4BE]") do
            a(href: @post.permalink,
              class: "text-[22px] font-semibold tracking-[0.01em] text-[#0F0E0D] no-underline hover:underline leading-7 font-display") do
              @post.title
            end
            span(class: "text-[14px] tracking-[0.06em] uppercase text-[#6B6968] shrink-0 ml-10 font-display") do
              format_date(@post.date, "%b %Y").upcase
            end
          end
        end
      end
    end
  end
end
