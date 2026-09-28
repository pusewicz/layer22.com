# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # A single note, with links to the notes before and after it.
      class NotePage < Base
        NAV_LINK_CLASS = "text-[14px] text-[#C00000] underline hover:text-[#8A0000]"

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
            div(class: "w-full bg-[#F5F3F0]") do
              div(class: "max-w-[1080px] mx-auto px-6 pt-12 pb-8") do
                div(class: "max-w-[640px]") do
                  a(href: "/notes/",
                    class: "font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#C00000] no-underline " \
                           "hover:text-[#8A0000] block") { "Notes" }
                  render Shared::NoteEntry.new(site:, note: @note)
                  neighbours if @prev_note || @next_note
                end
              end
            end
            render Shared::YoutubeScript.new
          end
        end

        private

        def neighbours
          nav(class: "flex justify-between border-t border-[#E2DFDB] pt-4", aria_label: "More notes") do
            span { a(href: @prev_note.permalink, rel: "prev", class: NAV_LINK_CLASS) { "← Older" } if @prev_note }
            span { a(href: @next_note.permalink, rel: "next", class: NAV_LINK_CLASS) { "Newer →" } if @next_note }
          end
        end
      end
    end
  end
end
