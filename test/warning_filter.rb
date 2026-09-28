# frozen_string_literal: true

# The suite runs with Ruby's warnings on (see rakelib/test.rake), which the gems
# have plenty of. This drops Ruby's own warnings about anything but the
# project's files, and fails the run if there are any about those. Messages
# from Kernel#warn pass through untouched. Loaded with -r so it sees every
# file's load-time warnings.
module ProjectWarnings
  ROOT = File.expand_path("..", __dir__)
  PROJECT_FILE = %r{\A(?:#{Regexp.escape(ROOT)}/)?(?:lib|rakelib|test)/}
  RUBY_WARNING = /\A[^\s:]+:\d+: warning: /
  @seen = []

  class << self
    attr_reader :seen
  end

  def warn(message, **)
    if message.match?(PROJECT_FILE)
      ProjectWarnings.seen << message
    elsif message.match?(RUBY_WARNING)
      return
    end

    super
  end
end

Warning.extend(ProjectWarnings)

# Registered before minitest/autorun, so it runs after Minitest's own exit.
at_exit { exit(1) unless ProjectWarnings.seen.empty? }
