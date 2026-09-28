# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "lib"
  t.pattern = "test/**/*_test.rb"
  t.warning = true
  t.ruby_opts << "-rwarning_filter"
end

desc "Lint, then run the tests"
task default: %i[standard test]
