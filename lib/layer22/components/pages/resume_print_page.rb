# frozen_string_literal: true

module Layer22
  module Components
    module Pages
      # A standalone A4 rendering of _data/resume.yml, printed to
      # piotr-usewicz-resume.pdf by `rake resume:pdf`.
      class ResumePrintPage < Phlex::HTML
        STYLES = <<~CSS
          /* ../assets resolves correctly both when served (/resume-print/) and when
             printed from file://_site/resume-print/index.html */
          @font-face { font-family: 'Barlow Condensed'; font-weight: 600; font-style: normal;
            src: url('../assets/fonts/barlow-condensed-latin-600-normal.woff2') format('woff2'); }
          @font-face { font-family: 'Barlow Condensed'; font-weight: 500; font-style: normal;
            src: url('../assets/fonts/barlow-condensed-latin-500-normal.woff2') format('woff2'); }
          @page { size: A4; margin: 16mm 18mm; }
          * { box-sizing: border-box; margin: 0; padding: 0; }
          html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
          body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
                 font-size: 10pt; line-height: 1.45; color: #111; }
          a { color: inherit; text-decoration: none; }
          .name { font-family: 'Barlow Condensed', 'Arial Narrow', sans-serif;
                  font-weight: 600; font-size: 26pt; letter-spacing: .01em; }
          .meta { font-size: 8.5pt; color: #555; margin-top: 2pt; }
          .rule { border: 0; border-top: 1.2pt solid #C00000; width: 26pt; margin: 8pt 0 10pt; }
          .summary { color: #222; }
          h2 { font-family: 'Barlow Condensed', 'Arial Narrow', sans-serif; font-weight: 500;
               font-size: 9pt; letter-spacing: .16em; text-transform: uppercase;
               color: #C00000; margin: 12pt 0 5pt; }
          .entry { margin-bottom: 8pt; break-inside: avoid; }
          .entry-head { display: flex; justify-content: space-between; align-items: baseline; gap: 12pt; }
          .role { font-weight: 700; }
          .co { color: #444; font-weight: 400; }
          .dates { color: #555; font-size: 9pt; white-space: nowrap; }
          .loc, .context { font-size: 9pt; color: #555; }
          .context { margin-top: 1pt; }
          ul { margin: 3pt 0 0 11pt; color: #222; }
          li { margin-bottom: 1.5pt; }
          .os-intro { color: #444; margin-bottom: 3pt; }
          .skills { display: grid; grid-template-columns: 70pt 1fr; row-gap: 2pt; column-gap: 10pt; }
          .skills dt { color: #555; font-size: 9pt; }
        CSS

        # +resume+ is the parsed _data/resume.yml.
        def initialize(resume:)
          @resume = resume
        end

        def view_template
          doctype
          html(lang: "en") do
            head do
              meta(charset: "UTF-8")
              meta(name: "robots", content: "noindex")
              title { "#{basics["name"]} — Resume" }
              style { raw safe(STYLES) }
            end
            body do
              header do
                div(class: "name") { basics["name"] }
                div(class: "meta") { meta_line }
                hr(class: "rule")
              end
              p(class: "summary") { @resume["summary"] }
              experience
              open_source
              skills
            end
          end
        end

        private

        def basics
          @resume["basics"]
        end

        def meta_line
          links = basics["links"].map { |link| " · #{link["label"]}" }.join
          "#{basics["headline"]} · #{basics["location"]} — #{basics["availability"]} · #{basics["email"]}#{links}"
        end

        def experience
          h2 { "Experience" }
          @resume["experience"].each do |job|
            div(class: "entry") do
              div(class: "entry-head") do
                span do
                  span(class: "role") { job["role"] }
                  detail("co", "· #{job["company"]}") if job["company"]
                  detail("co", "— #{job["tagline"]}") if job["tagline"]
                  detail("loc", "· #{job["location"]}") if job["location"]
                end
                span(class: "dates") { "#{job["start"]} – #{job["end"]}" }
              end
              div(class: "context") { job["context"] } if job["context"]
              ul { job["bullets"].each { |bullet| li { bullet } } } if job["bullets"]
            end
          end
        end

        def detail(css_class, text)
          whitespace
          span(class: css_class) { text }
        end

        def open_source
          h2 { "Open Source" }
          p(class: "os-intro") { @resume["open_source"]["intro"] }
          ul do
            @resume["open_source"]["projects"].each do |project|
              li do
                strong { project["name"] }
                plain " — #{project["note"]}"
              end
            end
          end
        end

        def skills
          h2 { "Skills" }
          dl(class: "skills") do
            @resume["skills"].each do |skill|
              dt { skill["group"] }
              dd { skill["items"] }
            end
            dt { "Languages" }
            dd { @resume["languages"] }
          end
        end
      end
    end
  end
end
