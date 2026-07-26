desc "Build the site for Cloudflare"
task build: [:tailwind, :jekyll, :redirects, :resume_freshness]

RESUME_PDF = "piotr-usewicz-resume.pdf"

desc "Warn if the committed resume PDF is older than its sources"
task :resume_freshness do
  sources = ["_data/resume.yml", "_layouts/resume_print.html"]
  if File.exist?(RESUME_PDF)
    stale = sources.select { |f| File.exist?(f) && File.mtime(f) > File.mtime(RESUME_PDF) }
    warn "WARNING: #{RESUME_PDF} is older than #{stale.join(", ")} — run `rake resume:pdf`" if stale.any?
  else
    warn "WARNING: #{RESUME_PDF} missing — run `rake resume:pdf`"
  end
end

namespace :resume do
  desc "Regenerate the resume PDF with headless Chrome (local only)"
  task pdf: :build do
    chrome = ENV["CHROME_BIN"] || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    abort "Chrome not found at #{chrome} — set CHROME_BIN" unless File.exist?(chrome)
    src = File.expand_path("_site/resume-print/index.html")
    sh chrome, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
       "--virtual-time-budget=5000", "--print-to-pdf=#{RESUME_PDF}", "file://#{src}"
    puts "Wrote #{RESUME_PDF}"
  end
end

desc "Install JS dependencies"
task :bun_install do
  sh "bun install"
end

desc "Build Tailwind CSS"
task tailwind: [:bun_install] do
  sh "bunx tailwindcss -i ./tailwind.input.css -o ./assets/css/tailwind.css --minify"
end

desc "Build site with Jekyll"
task :jekyll do
  sh "jekyll build"
end

desc "Copy the redirects file to the _site directory"
task :redirects do
  cp "_redirects", "_site/"
end

desc "Create a new TIL post"
task :til, [:title] do |t, args|
  title = args[:title] || "New TIL"
  date = Time.now

  template = <<~TEMPLATE
    ---
    layout: til
    title: #{title}
    date: #{date.strftime("%Y-%m-%d %H:%M:%S %z")}
    tags: []
    ---

    <!-- Add your TIL content here -->
  TEMPLATE
  dest = "_til/#{date.year}/#{date.strftime("%m")}/#{date.strftime("%Y-%m-%d")}-#{title.downcase.gsub(/\s+/, "-")}.md"
  mkdir_p File.dirname(dest)
  puts "Creating new TIL post at #{dest}"
  File.write(dest, template)
end
