require 'slim'
require_relative 'lib/middleman/syntax/syntax_extension'

compass_config do |config|
  config.output_style = :compact
end

sprockets.append_path File.join root, 'bower_components'

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true
set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'

page "/feed.xml", :layout => false
page "/sitemap.xml", :layout => false
page "/CNAME", :directory_index => false

activate :automatic_image_sizes
activate :meta_tags
activate :minify_html

activate :blog do |blog|
  blog.layout = "article_layout"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.branch = "master" # default: gh-pages
end

activate :directory_indexes
activate :syntax

helpers do
  def copyright_years(start_year)
    end_year = Date.today.year
    if start_year == end_year
      start_year.to_s
    else
      start_year.to_s + '-' + end_year.to_s
    end
  end

  def format_calendar_date(page_type, year, month, day)
    case page_type
    when 'day'
     Date.new(year, month, day).strftime('%b %e %Y')
    when 'month'
      Date.new(year, month, 1).strftime('%b %Y')
    when 'year'
      year
    end
  end

  def pretty_date(date)
    date.strftime('%B %d, %Y')
  end
end

configure :development do
  # Reload the browser automatically whenever files change
  activate :livereload
end

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :imageoptim
  activate :autoprefixer
end
