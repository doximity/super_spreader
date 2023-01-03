# frozen_string_literal: true

require "active_support/core_ext/time"

module SuperSpreader
  class PeakSchedule
    def initialize(on_peak_wday_range:, on_peak_hour_range:, timezone:)
      @on_peak_wday_range = on_peak_wday_range
      @on_peak_hour_range = on_peak_hour_range
      @timezone = timezone
    end

    def on_peak?(time = Time.current)
      time_in_zone = time.in_time_zone(@timezone)

      is_on_peak_day = @on_peak_wday_range.cover?(time_in_zone.wday)
      is_on_peak_hour = @on_peak_hour_range.cover?(time_in_zone.hour)

      is_on_peak_day && is_on_peak_hour
    end
  end
end
