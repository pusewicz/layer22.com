# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # The resume as a web page, marked up as an h-resume, from _data/resume.yml.
      class ResumePage < Base
        AVATAR_URL = "https://www.gravatar.com/avatar/dcbf676f860477e44b275cae5d6318a4.jpg?s=176"

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
            article(class: "h-resume") do
              div(class: "resume-sheet") do
                introduction
                p(class: "p-note resume-summary") { @resume["summary"] }
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
          header(class: "h-card resume-header") do
            img(src: AVATAR_URL, width: "176", height: "176", alt: config.author_name,
                class: "u-photo author-photo", loading: "lazy")
            div(class: "resume-identity") do
              h1(class: "p-name resume-name") { basics["name"] }
              p(class: "p-job-title resume-headline") { basics["headline"] }
              p(class: "resume-location") do
                span(class: "p-locality") { basics["location"] }
                plain " · #{basics["availability"]}"
              end
              p(class: "resume-links") do
                a(class: "u-email", href: "mailto:#{basics["email"]}") { basics["email"] }
                basics["links"].each { |link| a(class: "u-url", rel: "me", href: link["url"]) { link["label"] } }
                a(href: "/piotr-usewicz-resume.pdf") { "Download PDF ↓" }
              end
            end
          end
        end

        def experience
          h2(class: "display-label resume-lead-heading") { "Experience" }
          @resume["experience"].each { |job| job_section(job) }
        end

        def job_section(job)
          section(class: "resume-row resume-job") do
            div(class: "resume-dates") { "#{job["start"]} – #{job["end"]}" }
            div(class: "resume-job-body") do
              h3(class: "resume-job-title") { job_title(job) }
              p(class: "resume-job-location") { job["location"] } if job["location"]
              p(class: "resume-job-context") { job["context"] } if job["context"]
              if job["bullets"]
                ul(class: "resume-list") do
                  job["bullets"].each { |bullet| li { bullet } }
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
              a(href: job["company_url"], class: "resume-company") { job["company"] }
            else
              plain job["company"]
            end
          end
          if job["tagline"]
            whitespace
            span(class: "resume-tagline") { "— #{job["tagline"]}" }
          end
        end

        def quote(quote)
          blockquote(class: "resume-quote") do
            p { "“#{quote["text"]}”" }
            footer do
              plain "— "
              a(href: quote["source"]) { quote["name"] }
              plain ", #{quote["title"]}"
            end
          end
        end

        def open_source
          h2(class: "display-label resume-heading") { "Open Source" }
          p(class: "resume-intro") { @resume["open_source"]["intro"] }
          ul(class: "resume-list") do
            @resume["open_source"]["projects"].each do |project|
              li do
                a(href: project["url"]) { project["name"] }
                plain " — #{project["note"]}"
              end
            end
          end
        end

        def skills
          h2(class: "display-label resume-heading") { "Skills" }
          dl(class: "resume-skills") do
            @resume["skills"].each { |skill| skill_row(skill["group"], skill["items"]) }
            skill_row("Languages", @resume["languages"])
          end
        end

        def skill_row(group, items)
          div(class: "resume-row resume-skill") do
            dt { group }
            dd { items }
          end
        end
      end
    end
  end
end
