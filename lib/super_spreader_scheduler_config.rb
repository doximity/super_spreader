# frozen_string_literal: true

require "super_spreader/peak_schedule"
require "redis_model"

class SuperSpreaderSchedulerConfig < RedisModel
  attribute :batch_size, :integer
  attribute :duration, :integer
  attribute :job_class_name, :string

  attribute :per_second_on_peak, :float
  attribute :per_second_off_peak, :float

  # UTC crosses the date boundary in an inconvenient way, so allow specifying
  # the timezone
  attribute :on_peak_timezone, :string
  attribute :on_peak_hour_begin, :integer
  attribute :on_peak_hour_end, :integer
  attribute :on_peak_wday_begin, :integer
  attribute :on_peak_wday_end, :integer

  attr_writer :schedule

  def job_class
    job_class_name.constantize
  end

  def super_spreader_config
    [job_class, job_class.model_class]
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
      begin
        SuperSpreader::PeakSchedule.new(
          on_peak_wday_range: on_peak_wday_begin..on_peak_wday_end,
          on_peak_hour_range: on_peak_hour_begin..on_peak_hour_end,
          timezone: on_peak_timezone
        )
      end
  end
end
