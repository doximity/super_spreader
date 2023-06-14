# frozen_string_literal: true

require "super_spreader/peak_schedule"
require "super_spreader/redis_model"

module SuperSpreader
  class SchedulerConfig < RedisModel
    # The job class to enqueue on each run of the scheduler.
    attribute :job_class_name, :string
    # The number of records to process in each invocation of the job class.
    attribute :batch_size, :integer
    # The amount of work to enqueue, in seconds.
    attribute :duration, :integer

    # The number of jobs to enqueue per second, allowing for fractional amounts
    # such as 1 job every other second using `0.5`.
    attribute :per_second_on_peak, :float
    # The same as per_second_on_peak, but for times that are not identified as
    # on-peak.
    attribute :per_second_off_peak, :float

    # This section manages the definition "on peak."  Compare this terminology
    # to bus or train schedules.

    # The timezone to use for time calculations.
    #
    # Example: "America/Los_Angeles" for Pacific time
    attribute :on_peak_timezone, :string
    # The 24-hour hour on which on-peak application usage starts.
    #
    # Example: 5 for 5 AM
    attribute :on_peak_hour_begin, :integer
    # The 24-hour hour on which on-peak application usage ends.
    #
    # Example: 17 for 5 PM
    attribute :on_peak_hour_end, :integer
    # The wday value on which on-peak application usage starts.
    #
    # Example: 1 for Monday
    attribute :on_peak_wday_begin, :integer
    # The wday value on which on-peak application usage ends.
    #
    # Example: 5 for Friday
    attribute :on_peak_wday_end, :integer

    attr_writer :schedule

    def job_class
      job_class_name.constantize
    end

    def super_spreader_config
      [job_class, job_class.super_spreader_model_class]
    end

    def spread_options
      {
        batch_size: batch_size,
        duration: duration,
        per_second: per_second
      }
    end

    def per_second
      schedule.on_peak? ? per_second_on_peak : per_second_off_peak
    end

    private

    def schedule
      @schedule ||=
        PeakSchedule.new(
          on_peak_wday_range: on_peak_wday_begin..on_peak_wday_end,
          on_peak_hour_range: on_peak_hour_begin..on_peak_hour_end,
          timezone: on_peak_timezone
        )
    end
  end
end
