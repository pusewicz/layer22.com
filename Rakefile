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
