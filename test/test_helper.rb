# frozen_string_literal: true

# Dates render in the site's timezone, which Site sets process-wide. Pin it
# before anything loads so the suite behaves the same on every machine.
ENV["TZ"] = "Europe/Madrid"

# Likewise files and subprocess output the tests read back are UTF-8, whatever
# locale the machine runs in. Ruby warns about changing it, hence the silence.
verbose, $VERBOSE = $VERBOSE, nil
Encoding.default_external = Encoding::UTF_8
$VERBOSE = verbose

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require_relative "warning_filter"
require "layer22"
require "minitest/autorun"
require "minitest/mock"
require "nokogiri"
require "tmpdir"
require "yaml"

Layer22.logger = Logger.new(File::NULL)

module Layer22
  # Base class for the suite's tests, with helpers for the fixture site and for
  # throwaway sites in a temporary directory. Loaders read from the working
  # directory, so tests that build a Site or run a generator do it inside
  # +in_fixture_site+ or +with_site+ (never nested). The suite must not run in
  # parallel: the working directory and ENV are process-global.
  class TestCase < Minitest::Test
    FIXTURE_ROOT = File.expand_path("fixtures/site", __dir__)
    STYLESHEETS = %w[normalize base components syntax].to_h { |name| ["styles/#{name}.css", "/* #{name} */\n"] }.freeze

    # Runs the block with the fixture site as the working directory.
    def in_fixture_site(&)
      Dir.chdir(FIXTURE_ROOT, &)
    end

    # Returns the fixture site with its content and CSS loaded. It is loaded once
    # and shared, as a Site's content is immutable.
    def fixture_site
      TestCase.fixture_site
    end

    def self.fixture_site
      @fixture_site ||= Dir.chdir(FIXTURE_ROOT) { Site.new.load_content.load_css }
    end

    # Returns the fixture's site.yml as a Hash, with +overrides+ merged in.
    def fixture_config(**overrides)
      YAML.safe_load_file(File.join(FIXTURE_ROOT, "site.yml")).merge(overrides.transform_keys(&:to_s))
    end

    # Yields the path of a scratch site, with it as the working directory. It has
    # the fixture's site.yml (with +config+ merged in) and empty stylesheets, plus
    # +files+, a Hash of relative path => contents that may replace either.
    def with_site(files = {}, config: {})
      Dir.mktmpdir("layer22-test") do |dir|
        base = STYLESHEETS.merge("site.yml" => YAML.dump(fixture_config.merge(config.transform_keys(&:to_s))))
        base.merge(files).each { |path, contents| write_file(File.join(dir, path), contents) }
        Dir.chdir(dir) { yield dir }
      end
    end

    # Writes +contents+ to +path+, creating its directory.
    def write_file(path, contents)
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, contents)
    end

    # Runs the block with +encoding+ as the default external encoding, as under a
    # C locale. The setting is process-global, so keep the block small.
    def with_default_external(encoding)
      original = Encoding.default_external
      verbose, $VERBOSE = $VERBOSE, nil
      Encoding.default_external = encoding
      $VERBOSE = verbose
      yield
    ensure
      $VERBOSE = nil
      Encoding.default_external = original
      $VERBOSE = verbose
    end

    # Parses an HTML document or fragment.
    def parse_html(html)
      Nokogiri::HTML5(html)
    end

    # Parses XML strictly, so malformed output fails the test.
    def parse_xml(xml)
      Nokogiri::XML(xml, &:strict)
    end

    # Runs the block with a directory holding only +executables+ (name => shell
    # script body) as the whole PATH, so external programs are exactly those.
    def with_path(executables = {})
      Dir.mktmpdir("layer22-bin") do |dir|
        executables.each do |name, body|
          path = File.join(dir, name)
          File.write(path, "#!/bin/sh\n#{body}\n")
          File.chmod(0o755, path)
        end
        original = ENV["PATH"]
        ENV["PATH"] = dir
        yield dir
      ensure
        ENV["PATH"] = original
      end
    end
  end
end
