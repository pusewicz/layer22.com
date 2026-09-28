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
            div(class: "h-feed site-width page-content") do
              h1(class: "p-name page-title") { "Writing" }
              site.posts.reverse.group_by { |post| post.date.year }.each { |year, posts| year_section(year, posts) }
            end
          end
        end

        private

        def year_section(year, posts)
          div(class: "post-group") do
            h2(class: "post-group-year") { year.to_s }
            posts.each do |post|
              div(class: "h-entry post-row") do
                a(href: absolute_url(post.permalink), class: "p-name u-url") { post.title }
                time(class: "dt-published display-caption post-row-date", datetime: post.date.xmlschema) do
                  format_date(post.date, "%b %Y")
                end
              end
            end
          end
        end
      end
    end
  end
end
