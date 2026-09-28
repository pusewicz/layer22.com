# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # The resume as a web page, marked up as an h-resume, from _data/resume.yml.
      class ResumePage < Base
        AVATAR_URL = "https://www.gravatar.com/avatar/dcbf676f860477e44b275cae5d6318a4.jpg?s=176"
        SECTION_HEADING_CLASS = "font-display text-[14px] font-medium tracking-[0.12em] uppercase text-[#6B6968]"
        LIST_CLASS = "text-[15px] leading-relaxed text-[#3A3836]"

        def initialize(site:, page:)
          super(site:)
          @page = page
          @resume = site.data.fetch("resume")
        end

        def view_template
          render Layouts::ApplicationLayout.new(
            site:,
            layout: "resume",
            title: @page.title,
            seo: {url: @page.permalink, description: @page.description, modified_at: @page.last_modified_at}
          ) do
            article(class: "w-full bg-[#F5F3F0] h-resume") do
              div(class: "max-w-[820px] mx-auto px-6 pt-12 pb-16") do
                introduction
                p(class: "p-note text-[17px] leading-relaxed text-[#0F0E0D] mb-12") { @resume["summary"] }
                experience
                open_source
                skills
              end
            end
          end
        end

        private

        def basics
          @resume["basics"]
        end

        def introduction
          header(class: "h-card flex items-start gap-5 mb-10") do
            img(src: AVATAR_URL, width: "176", height: "176", alt: config.author_name,
                class: "u-photo w-[88px] h-[88px] rounded-full object-cover shrink-0", loading: "lazy")
            div(class: "min-w-0") do
              h1(class: "p-name font-display text-[44px] leading-none font-semibold text-[#0F0E0D] m-0") { basics["name"] }
              p(class: "p-job-title text-[17px] text-[#0F0E0D] mt-1 mb-0") { basics["headline"] }
              p(class: "text-[14px] text-[#6B6968] mt-1 mb-2") do
                span(class: "p-locality") { basics["location"] }
                plain " · #{basics["availability"]}"
              end
              p(class: "text-[14px] mt-0 mb-0 flex flex-wrap gap-x-4 gap-y-1") do
                a(class: "u-email", href: "mailto:#{basics["email"]}") { basics["email"] }
                basics["links"].each { |link| a(class: "u-url", rel: "me", href: link["url"]) { link["label"] } }
                a(href: "/piotr-usewicz-resume.pdf", class: "text-[#C00000]") { "Download PDF ↓" }
              end
            end
          end
        end

        def experience
          h2(class: "#{SECTION_HEADING_CLASS} mb-6") { "Experience" }
          @resume["experience"].each { |job| job_section(job) }
        end

        def job_section(job)
          section(class: "grid grid-cols-1 md:grid-cols-[110px_1fr] gap-x-8 gap-y-1 mb-9") do
            div(class: "text-[14px] text-[#6B6968] tabular-nums pt-[3px]") { "#{job["start"]} – #{job["end"]}" }
            div(class: "min-w-0") do
              h3(class: "text-[18px] font-semibold text-[#0F0E0D] m-0") { job_title(job) }
              p(class: "text-[13px] text-[#6B6968] mt-0.5 mb-0") { job["location"] } if job["location"]
              p(class: "text-[15px] text-[#6B6968] mt-2 mb-0") { job["context"] } if job["context"]
              if job["bullets"]
                ul(class: "mt-2 mb-0 pl-5 #{LIST_CLASS}") do
                  job["bullets"].each { |bullet| li(class: "mb-1.5") { bullet } }
                end
              end
              quote(job["quote"]) if job["quote"]
            end
          end
        end

        def job_title(job)
          plain job["role"]
          if job["company"]
            plain " · "
            if job["company_url"]
              a(href: job["company_url"], class: "no-underline hover:underline") { job["company"] }
            else
              plain job["company"]
            end
          end
          if job["tagline"]
            whitespace
            span(class: "font-normal text-[#6B6968]") { "— #{job["tagline"]}" }
          end
        end

        def quote(quote)
          blockquote(class: "border-l-2 border-[#C00000] pl-4 mt-4 mb-0 italic text-[15px] text-[#57544F]") do
            p(class: "m-0") { "“#{quote["text"]}”" }
            footer(class: "not-italic text-[13px] text-[#6B6968] mt-1") do
              plain "— "
              a(href: quote["source"]) { quote["name"] }
              plain ", #{quote["title"]}"
            end
          end
        end

        def open_source
          h2(class: "#{SECTION_HEADING_CLASS} mt-14 mb-4") { "Open Source" }
          p(class: "text-[15px] text-[#6B6968] mb-4") { @resume["open_source"]["intro"] }
          ul(class: "pl-5 #{LIST_CLASS} mb-0") do
            @resume["open_source"]["projects"].each do |project|
              li(class: "mb-1.5") do
                a(href: project["url"]) { project["name"] }
                plain " — #{project["note"]}"
              end
            end
          end
        end

        def skills
          h2(class: "#{SECTION_HEADING_CLASS} mt-14 mb-4") { "Skills" }
          dl(class: "m-0") do
            @resume["skills"].each { |skill| skill_row(skill["group"], skill["items"], "mb-2") }
            skill_row("Languages", @resume["languages"], "mb-0")
          end
        end

        def skill_row(group, items, margin)
          div(class: "grid grid-cols-1 md:grid-cols-[110px_1fr] gap-x-8 #{margin}") do
            dt(class: "text-[14px] text-[#6B6968]") { group }
            dd(class: "m-0 text-[15px] text-[#3A3836]") { items }
          end
        end
      end
    end
  end
end
