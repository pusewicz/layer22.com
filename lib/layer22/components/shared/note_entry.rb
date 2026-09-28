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
          article(class: "h-entry py-8") do
            a(class: "u-url no-underline", href: @note.permalink) do
              time(class: "dt-published font-display text-[13px] tracking-[0.06em] uppercase text-[#9B9895] " \
                          "hover:text-[#6B6968]",
                   datetime: @note.date.xmlschema) { format_date(@note.date, "%b %-d, %Y · %H:%M") }
            end
            div(class: "e-content mt-3") do
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
