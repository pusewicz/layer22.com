desc "Build the site for Cloudflare"
task build: [:jekyll, :redirects]

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
