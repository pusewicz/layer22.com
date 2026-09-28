# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class ResumePrintPageTest < TestCase
        def resume_data(overrides = {})
          {
            "basics" => {
              "name" => "Grace Hopper",
              "headline" => "Rear Admiral",
              "location" => "New York, USA",
              "availability" => "Retired",
              "email" => "grace@example.test",
              "links" => [
                {"label" => "example.test", "url" => "https://example.test"},
                {"label" => "github.com/grace", "url" => "https://github.com/grace"}
              ]
            },
            "summary" => "Invented the first compiler.",
            "experience" => [
              {
                "role" => "Senior Engineer", "company" => "Acme", "tagline" => "rockets", "location" => "Remote",
                "start" => "Jan 2020", "end" => "present", "context" => "Building things.",
                "bullets" => ["Shipped A.", "Shipped B."]
              },
              {"role" => "Engineer", "company" => "Initech", "start" => "Jan 2015", "end" => "Dec 2019"},
              {"role" => "Sabbatical", "start" => "2014", "end" => "2014"}
            ],
            "open_source" => {
              "intro" => "Writing open source.",
              "projects" => [{"name" => "cobol", "url" => "https://github.com/grace/cobol", "note" => "a language"}]
            },
            "skills" => [{"group" => "Primary", "items" => "Ruby, Rails"}, {"group" => "Frontend", "items" => "JavaScript"}],
            "languages" => "English"
          }.merge(overrides)
        end

        def render_html(resume = resume_data)
          ResumePrintPage.new(resume:).call
        end

        def render_print(resume = resume_data)
          parse_html(render_html(resume))
        end

        def entries(doc)
          doc.css("body > div")
        end

        def test_renders_a_standalone_html5_document
          html = render_html
          doc = parse_html(html)

          assert html.start_with?("<!doctype html>")
          assert_equal "en", doc.at_css("html")["lang"]
          assert_equal "UTF-8", doc.at_css("meta[charset]")["charset"]
        end

        def test_is_not_indexed_and_has_no_site_chrome
          doc = render_print

          assert_equal "noindex", doc.at_css("meta[name=robots]")["content"]
          assert_empty doc.css("nav, footer, main, link")
        end

        def test_titles_the_document_after_the_person
          assert_equal "Grace Hopper — Resume", render_print.at_css("title").text
        end

        def test_inlines_the_print_styles_unescaped
          style = render_print.at_css("head style")

          assert_includes style.text, "@page { size: A4;"
          assert_includes style.text, "font-family: 'Barlow Condensed'"
          assert_includes style.text, "../assets/fonts/barlow-condensed-latin-600-normal.woff2"
        end

        def test_header_names_the_person_and_summarises_their_contact_details
          header = render_print.at_css("body > header")

          assert_equal ["Grace Hopper",
            "Rear Admiral · New York, USA — Retired · grace@example.test · example.test · github.com/grace"],
            header.css("div").map(&:text)
        end

        def test_renders_the_summary
          assert_equal "Invented the first compiler.", render_print.at_css("body > p").text
        end

        def test_sections_appear_in_order
          assert_equal ["Experience", "Open Source", "Skills"], render_print.css("body > h2").map(&:text)
        end

        def test_renders_an_entry_per_job_in_order
          heads = entries(render_print).map { |entry| entry.at_css("span").text }

          assert_equal ["Senior Engineer · Acme — rockets · Remote", "Engineer · Initech", "Sabbatical"], heads
        end

        def test_entry_shows_its_dates
          dates = entries(render_print).map { |entry| entry.css("span").last.text }

          assert_equal ["Jan 2020 – present", "Jan 2015 – Dec 2019", "2014 – 2014"], dates
        end

        def test_entry_shows_context_and_bullets
          entry = entries(render_print).first

          assert_equal "Building things.", entry.css("div").last.text
          assert_equal ["Shipped A.", "Shipped B."], entry.css("ul li").map(&:text)
        end

        def test_entry_omits_optional_details_when_absent
          bare = entries(render_print)[1]

          assert_equal 1, bare.css("div").size
          assert_empty bare.css("ul")
          assert_equal "Engineer · Initech", bare.at_css("span").text
        end

        def test_a_job_without_a_company_is_just_its_role
          sabbatical = entries(render_print).last

          assert_equal "Sabbatical", sabbatical.at_css("span").text
          assert_equal 1, sabbatical.css("div").size
        end

        def test_renders_open_source_projects
          doc = render_print
          intro = doc.css("body > h2")[1].next_element
          project = doc.css("body > ul").last.at_css("li")

          assert_equal "Writing open source.", intro.text
          assert_equal "cobol — a language", project.text
          assert_equal "cobol", project.at_css("strong").text
        end

        def test_renders_skills_and_languages_last
          skills = render_print.at_css("body > dl")

          assert_equal %w[Primary Frontend Languages], skills.css("dt").map(&:text)
          assert_equal ["Ruby, Rails", "JavaScript", "English"], skills.css("dd").map(&:text)
        end

        def test_escapes_text_from_the_data
          text = %(<b>Bold</b> & "quoted")
          job = resume_data["experience"].first.merge("role" => text, "bullets" => [text], "context" => text)
          basics = resume_data["basics"].merge("name" => text)
          doc = render_print(resume_data("summary" => text, "experience" => [job], "basics" => basics))

          assert_equal "#{text} — Resume", doc.at_css("title").text
          assert_equal text, doc.at_css("body > header div").text
          assert_equal text, doc.at_css("body > p").text
          assert_equal [text], doc.css("body ul li").first(1).map(&:text)
          assert_nil doc.at_css("body b")
        end
      end
    end
  end
end
