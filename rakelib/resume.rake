# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, "..", "lib"))
require "layer22"

RESUME_PDF = "piotr-usewicz-resume.pdf"
RESUME_SOURCES = ["_data/resume.yml", "lib/layer22/components/pages/resume_print_page.rb"].freeze

# Compares commit times rather than mtimes, which clones and checkouts reset
# in arbitrary order.
desc "Warn if the committed resume PDF is older than its sources"
task :resume_freshness do
  if File.exist?(RESUME_PDF)
    pdf_time = Layer22::Content::LastModified.for(RESUME_PDF)
    stale = RESUME_SOURCES.select { |f| File.exist?(f) && Layer22::Content::LastModified.for(f) > pdf_time }
    warn "WARNING: #{RESUME_PDF} is older than #{stale.join(", ")} — run `rake resume:pdf`" if stale.any?
  else
    warn "WARNING: #{RESUME_PDF} missing — run `rake resume:pdf`"
  end
end

namespace :resume do
  desc "Regenerate the resume PDF with headless Chrome (local only)"
  task pdf: "build:fast" do
    chrome = ENV["CHROME_BIN"] || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    abort "Chrome not found at #{chrome} — set CHROME_BIN" unless File.exist?(chrome)
    src = File.expand_path("_site/resume-print/index.html")
    sh chrome, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
      "--virtual-time-budget=5000", "--print-to-pdf=#{RESUME_PDF}", "file://#{src}"
    puts "Wrote #{RESUME_PDF}"
  end
end
