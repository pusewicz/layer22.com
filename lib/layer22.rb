# frozen_string_literal: true

require "zeitwerk"
require "logger"

module Layer22
  class << self
    def logger
      @logger ||= Logger.new($stdout, formatter: method(:log_formatter))
    end

    attr_writer :logger

    def loader
      @loader ||= begin
        loader = Zeitwerk::Loader.new
        loader.tag = "layer22"
        loader.push_dir("#{__dir__}/layer22", namespace: Layer22)
        loader.inflector.inflect("til" => "TIL", "til_page" => "TilPage", "css" => "CSS", "seo_head" => "SeoHead")
        loader.ignore("#{__dir__}/layer22/dev_server.rb")
        loader.enable_reloading
        loader
      end
    end

    def reload!
      changed = managed_files.any? { |f| File.mtime(f) > @last_reload_at }
      return unless changed

      logger.info("Reloading code...")
      loader.reload
      @last_reload_at = Time.now
    end

    def managed_files
      Dir.glob("#{__dir__}/layer22/**/*.rb") - ["#{__dir__}/layer22/dev_server.rb"]
    end

    private

    def log_formatter(severity, time, _progname, message)
      timestamp = time.strftime("%H:%M:%S")
      "#{timestamp} [#{severity.downcase}] #{message}\n"
    end
  end
end

Layer22.loader.setup
Layer22.instance_variable_set(:@last_reload_at, Time.now)
