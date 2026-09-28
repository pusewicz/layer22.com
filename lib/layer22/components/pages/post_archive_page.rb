# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # The posts of one year, month, day or tag, newest first.
      class PostArchivePage < Base
        # +layout+ and +title+ become the page's body classes, +heading+ its h1,
        # and +date_format+ formats each post's date.
        def initialize(site:, layout:, url:, heading:, posts:, date_format:, title: nil)
          super(site:)
          @layout = layout
          @url = url
          @heading = heading
          @posts = posts
          @date_format = date_format
          @title = title
        end

        def view_template
          render Layouts::ApplicationLayout.new(site:, layout: @layout, title: @title, seo: {url: @url}) do
            div(class: "w-full bg-[#F5F3F0]") do
              div(class: "max-w-[1080px] mx-auto px-6 pt-12 pb-8") do
                a(href: "/archive",
                  class: "font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#C00000] no-underline " \
                         "hover:text-[#8A0000] mb-4 block") { "Writing" }
                h1(class: "font-display text-[40px] font-bold tracking-[-0.02em] text-[#0F0E0D] leading-[1.15] m-0") do
                  @heading
                end
                div(class: "mt-8") { @posts.each { |post| entry(post) } }
              end
            end
          end
        end

        private

        def entry(post)
          div(class: "flex items-baseline justify-between py-[10px] border-b border-[#E2DFDB]") do
            a(href: post.permalink, class: "text-[17px] text-[#0F0E0D] no-underline hover:text-[#C00000] leading-6") do
              post.title
            end
            span(class: "font-display text-[13px] tracking-[0.06em] uppercase text-[#9B9895] shrink-0 ml-10") do
              format_date(post.date, @date_format)
            end
          end
        end
      end
    end
  end
end
