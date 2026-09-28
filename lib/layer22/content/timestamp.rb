# frozen_string_literal: true

require "time"

module Layer22
  module Content
    # Parses front matter dates the way Jekyll does: into a Time in the local zone,
    # which Site sets from the timezone in site.yml.
    module Timestamp
      # Returns +value+ (a String, Date or Time) as a local Time, or nil when blank.
      # Raises ArgumentError naming +source+ when the value is not a date.
      def self.parse(value, source:)
        return if value.nil? || value.to_s.strip.empty?

        Time.parse(value.to_s).localtime
      rescue ArgumentError
        raise ArgumentError, "#{source}: invalid date #{value.inspect}"
      end
    end
  end
end
