# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # The notes stream: every note, newest first, as an h-feed.
      class NotesPage < Base
        def initialize(site:, page:)
          super(site:)
          @page = page
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "default",
            title: @page.title,
            seo: {url: @page.permalink, description: @page.description, modified_at: @page.last_modified_at}
          ) do
            div(class: "h-feed site-width page-content") do
              div(class: "reading-width") do
                div(class: "section-head") do
                  h1(class: "p-name page-title") { @page.title }
                  a(href: "/notes/feed.xml") { "RSS" }
                end
                div(class: "note-list") do
                  site.notes.reverse_each { |note| render Shared::NoteEntry.new(site:, note:) }
                end
              end
            end
            render Shared::YoutubeScript.new
          end
        end
      end
    end
  end
end
