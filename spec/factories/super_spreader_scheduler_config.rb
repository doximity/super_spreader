# frozen_string_literal: true

FactoryBot.define do
  factory :super_spreader_scheduler_config do
    batch_size { 70 }
    duration { 180 }
    job_class_name { "ExampleJob" }

    per_second_on_peak { 3.0 }
    per_second_off_peak { 9.0 }

    on_peak_timezone { "America/Los_Angeles" }
    on_peak_wday_begin { 1 } # Monday
    on_peak_wday_end { 5 } # Friday
    on_peak_hour_begin { 5 }
    on_peak_hour_end { 17 }
  end
end
