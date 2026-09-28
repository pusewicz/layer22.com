# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # A single note, with links to the notes before and after it.
      class NotePage < Base
        def initialize(site:, note:, prev_note: nil, next_note: nil)
          super(site:)
          @note = note
          @prev_note = prev_note
          @next_note = next_note
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "note",
            title: (@note.title unless @note.title.empty?),
            html_title: @note.label,
            seo: {
              kind: :article,
              url: @note.permalink,
              description: @note.description,
              published_at: @note.date,
              modified_at: @note.last_modified_at
            },
            extra_css: site.syntax_css
          ) do
            div(class: "site-width page-content") do
              div(class: "reading-width") do
                a(href: "/notes/", class: "section-kicker") { "Notes" }
                render Shared::NoteEntry.new(site:, note: @note)
                neighbours if @prev_note || @next_note
              end
            end
            render Shared::YoutubeScript.new
          end
        end

        private

        def neighbours
          nav(class: "prev-next note-pager", aria_label: "More notes") do
            span { a(href: @prev_note.permalink, rel: "prev") { "← Older" } if @prev_note }
            span { a(href: @next_note.permalink, rel: "next") { "Newer →" } if @next_note }
          end
        end
      end
    end
  end
end
