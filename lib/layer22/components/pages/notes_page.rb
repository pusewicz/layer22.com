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
            div(class: "w-full bg-[#F5F3F0]") do
              div(class: "h-feed max-w-[1080px] mx-auto px-6 pt-12 pb-8") do
                div(class: "max-w-[640px]") do
                  div(class: "flex items-baseline justify-between border-b border-[#C8C4BE] pb-3") do
                    h1(class: "p-name font-display text-[40px] font-bold tracking-[-0.02em] text-[#0F0E0D] leading-[1.15] m-0") do
                      @page.title
                    end
                    a(href: "/notes/feed.xml", class: "text-[14px] text-[#C00000] underline hover:text-[#8A0000]") { "RSS" }
                  end
                  div(class: "divide-y divide-[#E2DFDB]") do
                    site.notes.reverse_each { |note| render Shared::NoteEntry.new(site:, note:) }
                  end
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
