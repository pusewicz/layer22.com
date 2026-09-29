# frozen_string_literal: true

module Layer22
  # Asserts a Time's wall-clock reading and UTC offset together. Time#== compares
  # instants, so on its own it cannot tell whether a value was converted to the
  # local zone.
  module LocalTimeAssertions
    LOCAL_FORMAT = "%Y-%m-%d %H:%M:%S %z"

    # Fails unless +actual+ is a Time that reads +expected+ (e.g.
    # "2021-01-01 00:30:00 +0100") on its own clock.
    def assert_local_time(expected, actual, message = nil)
      assert_kind_of Time, actual, message
      assert_equal expected, actual.strftime(LOCAL_FORMAT), message
    end
  end
end
