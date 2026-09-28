# frozen_string_literal: true

module Layer22
  module Components
    module Shared
      # A note as an h-entry: its time, linking to its page, its text and its
      # link card, or player for a YouTube video.
      class NoteEntry < Base
        def initialize(site:, note:)
          super(site:)
          @note = note
        end

        def view_template
          article(class: "h-entry note-entry") do
            a(class: "u-url note-entry-permalink", href: @note.permalink) do
              time(class: "dt-published display-caption", datetime: @note.date.xmlschema) do
                format_date(@note.date, "%b %-d, %Y · %H:%M")
              end
            end
            div(class: "e-content note-entry-content") do
              div(class: "note-body") { raw safe(@note.body_html) } unless @note.body_html.empty?
              if @note.link&.youtube
                render YoutubeCard.new(site:, link: @note.link)
              elsif @note.link
                render LinkCard.new(site:, link: @note.link)
              end
            end
          end
        end
      end
    end
  end
end
