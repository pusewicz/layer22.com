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
            div(class: "site-width page-content") do
              a(href: "/archive", class: "section-kicker") { "Writing" }
              h1(class: "page-title") { @heading }
              div(class: "post-group") { @posts.each { |post| entry(post) } }
            end
          end
        end

        private

        def entry(post)
          div(class: "post-row") do
            a(href: post.permalink) { post.title }
            span(class: "display-caption post-row-date") { format_date(post.date, @date_format) }
          end
        end
      end
    end
  end
end
