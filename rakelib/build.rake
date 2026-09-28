# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, "..", "lib"))
require "layer22"

desc "Build the site for Cloudflare Pages"
task build: :resume_freshness do
  site = Layer22::Site.new
  site.build
end

desc "Build the site without WebP conversion (faster)"
task "build:fast" do
  site = Layer22::Site.new
  site.build(skip_webp: true)
end
