# frozen_string_literal: true

source "https://rubygems.org"

gem "phlex", "~> 2.0"
gem "commonmarker", "~> 2.10"
gem "rouge", "~> 5.0"
gem "nokogiri", "~> 1.19"
gem "fastimage", "~> 2.4"
gem "zeitwerk", "~> 2.7"
gem "rake", "~> 13.4", require: false
gem "builder", "~> 3.3"
gem "logger", "~> 1.7"

group :development do
  gem "rackup", "~> 2.0", require: false
end

group :development, :test do
  gem "rack", "~> 3.2", require: false
  gem "puma", "~> 8.1", require: false
  gem "standard", "~> 1.57", require: false
end

group :test do
  gem "minitest", "~> 6.1", require: false
  gem "minitest-mock", "~> 5.27", require: false
end
