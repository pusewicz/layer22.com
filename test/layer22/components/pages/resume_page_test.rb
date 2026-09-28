# frozen_string_literal: true

require "test_helper"

module Layer22
  module Components
    module Pages
      class ResumePageTest < TestCase
        RESUME_PAGE = <<~MD
          ---
          layout: resume
          title: Resume
          permalink: /resume
          description: Resume of Grace Hopper.
          ---
        MD

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
                "role" => "Senior Engineer", "company" => "Acme", "company_url" => "https://acme.test", "tagline" => "rockets",
                "location" => "Remote", "start" => "Jan 2020", "end" => "present", "context" => "Building things.",
                "bullets" => ["Shipped A.", "Shipped B."],
                "quote" => {"text" => "Great.", "name" => "Ada", "title" => "Boss", "source" => "https://example.test/recommendation"}
              },
              {"role" => "Engineer", "company" => "Initech", "start" => "Jan 2015", "end" => "Dec 2019"},
              {"role" => "Sabbatical", "tagline" => "learning", "start" => "2014", "end" => "2014"}
            ],
            "open_source" => {
              "intro" => "Writing open source.",
              "projects" => [{"name" => "cobol", "url" => "https://github.com/grace/cobol", "note" => "a language"}]
            },
            "skills" => [{"group" => "Primary", "items" => "Ruby, Rails"}, {"group" => "Frontend", "items" => "JavaScript"}],
            "languages" => "English"
          }.merge(overrides)
        end

        def with_resume_site(files)
          with_site(files) do
            site = Site.new.load_content.load_css
            yield site, site.pages.first
          end
        end

        def render_resume(data = resume_data)
          with_resume_site("_data/resume.yml" => YAML.dump(data), "_pages/resume.md" => RESUME_PAGE) do |site, page|
            parse_html(ResumePage.new(site:, page:).call)
          end
        end

        def jobs(doc)
          doc.css("article section")
        end

        def test_titles_the_document_and_body_after_the_page
          doc = render_resume

          assert_equal "Resume · fixture|site", doc.at_css("title").text
          assert_equal "layout--resume resume", doc.at_css("body")["class"]
          assert_equal "Resume of Grace Hopper.", doc.at_css("meta[name=description]")["content"]
        end

        def test_is_an_h_resume_with_an_h_card_header
          doc = render_resume

          assert doc.at_css("main article.h-resume header.h-card")
        end

        def test_header_names_the_person_and_their_role
          header = render_resume.at_css("article header")

          assert_equal "Grace Hopper", header.at_css("h1.p-name").text
          assert_equal "Rear Admiral", header.at_css(".p-job-title").text
          assert_equal "New York, USA", header.at_css(".p-locality").text
          assert_includes header.text, "New York, USA · Retired"
        end

        def test_header_photo_uses_the_site_authors_name
          photo = render_resume.at_css("article header img.u-photo")

          assert_equal "Ada Author", photo["alt"]
          assert_match %r{\Ahttps://www\.gravatar\.com/avatar/}, photo["src"]
        end

        def test_header_links_to_email_profiles_and_the_pdf
          links = render_resume.at_css("article header div p:last-child")

          assert_equal "mailto:grace@example.test", links.at_css("a.u-email")["href"]
          assert_equal "grace@example.test", links.at_css("a.u-email").text
          assert_equal [%w[example.test https://example.test], %w[github.com/grace https://github.com/grace]],
            links.css("a.u-url").map { |a| [a.text, a["href"]] }
          assert_equal ["me", "me"], links.css("a.u-url").map { |a| a["rel"] }
          assert_equal "/piotr-usewicz-resume.pdf", links.css("a").last["href"]
          assert_equal "Download PDF ↓", links.css("a").last.text
        end

        def test_header_has_no_profile_links_without_any
          data = resume_data("basics" => resume_data["basics"].merge("links" => []))

          assert_empty render_resume(data).css("article header a.u-url")
        end

        def test_renders_the_summary
          assert_equal "Invented the first compiler.", render_resume.at_css("article p.p-note").text
        end

        def test_sections_appear_in_order
          assert_equal ["Experience", "Open Source", "Skills"], render_resume.css("article h2").map(&:text)
        end

        def test_renders_a_section_per_job_in_order
          assert_equal ["Senior Engineer · Acme — rockets", "Engineer · Initech", "Sabbatical — learning"],
            jobs(render_resume).map { |job| job.at_css("h3").text }
        end

        def test_job_shows_its_dates
          assert_equal ["Jan 2020 – present", "Jan 2015 – Dec 2019", "2014 – 2014"],
            jobs(render_resume).map { |job| job.at_css("div").text }
        end

        def test_job_company_links_to_its_url
          job = jobs(render_resume).first

          assert_equal "https://acme.test", job.at_css("h3 a")["href"]
          assert_equal "Acme", job.at_css("h3 a").text
        end

        def test_job_company_without_a_url_is_plain_text
          assert_nil jobs(render_resume)[1].at_css("h3 a")
        end

        def test_job_shows_location_context_and_bullets
          job = jobs(render_resume).first

          assert_equal ["Remote", "Building things."], job.css("div > p").map(&:text)
          assert_equal ["Shipped A.", "Shipped B."], job.css("ul li").map(&:text)
        end

        def test_job_shows_its_quote
          quote = jobs(render_resume).first.at_css("blockquote")

          assert_equal "“Great.”", quote.at_css("p").text
          assert_equal "— Ada, Boss", quote.at_css("footer").text
          assert_equal "https://example.test/recommendation", quote.at_css("footer a")["href"]
        end

        def test_job_omits_optional_details_when_absent
          bare = jobs(render_resume)[1]

          assert_empty bare.css("p, ul, blockquote")
          assert_empty jobs(render_resume).last.css("p, ul, blockquote")
        end

        def test_job_without_a_company_shows_only_role_and_tagline
          title = jobs(render_resume).last.at_css("h3")

          assert_equal "Sabbatical — learning", title.text
          assert_nil title.at_css("a")
        end

        def test_renders_open_source_projects
          doc = render_resume
          intro = doc.css("article h2")[1].next_element
          project = doc.css("article ul").last.at_css("li")

          assert_equal "Writing open source.", intro.text
          assert_equal "cobol — a language", project.text
          assert_equal "https://github.com/grace/cobol", project.at_css("a")["href"]
        end

        def test_renders_skills_and_languages_last
          skills = render_resume.at_css("article dl")

          assert_equal %w[Primary Frontend Languages], skills.css("dt").map(&:text)
          assert_equal ["Ruby, Rails", "JavaScript", "English"], skills.css("dd").map(&:text)
        end

        def test_escapes_text_from_the_data
          text = %(<b>Bold</b> & "quoted")
          job = resume_data["experience"].first.merge("role" => text, "bullets" => [text], "context" => text)
          doc = render_resume(resume_data("summary" => text, "experience" => [job]))

          assert_equal text, doc.at_css("article p.p-note").text
          assert_equal text, doc.at_css("article section h3").text.split(" · ").first
          assert_equal [text], doc.css("article section li").map(&:text)
          assert_nil doc.at_css("article b")
        end

        def test_seo_describes_the_page
          doc = render_resume

          assert_equal "https://example.test/resume", doc.at_css("link[rel=canonical]")["href"]
          assert_equal "website", doc.at_css("meta[property='og:type']")["content"]
        end

        def test_requires_resume_data
          with_resume_site("_pages/resume.md" => RESUME_PAGE) do |site, page|
            assert_raises(KeyError) { ResumePage.new(site:, page:) }
          end
        end
      end
    end
  end
end
