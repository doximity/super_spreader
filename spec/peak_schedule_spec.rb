# frozen_string_literal: true

require "spec_helper"

RSpec.describe SuperSpreader::PeakSchedule do
  describe "#on_peak?" do
    it "categorizes times into on- or off-peak" do
      schedule = described_class.new(on_peak_wday_range: 1..5, # M-F
                                     on_peak_hour_range: 4..18,
                                     timezone: "America/Los_Angeles")

      # Thursday
      assert_off_peak(schedule, "2021-01-07T00:00:00-08:00")
      assert_off_peak(schedule, "2021-01-07T03:00:00-08:00")
      assert_off_peak(schedule, "2021-01-07T03:59:59-08:00")
      assert_on_peak(schedule,  "2021-01-07T04:00:00-08:00")
      assert_on_peak(schedule,  "2021-01-07T11:30:00-08:00")
      assert_on_peak(schedule,  "2021-01-07T18:00:00-08:00")
      assert_on_peak(schedule,  "2021-01-07T18:59:59-08:00")
      assert_off_peak(schedule, "2021-01-07T19:00:00-08:00")
      assert_off_peak(schedule, "2021-01-07T23:59:59-08:00")

      # Sunday
      assert_off_peak(schedule, "2021-01-10T00:00:00-08:00")
      assert_off_peak(schedule, "2021-01-10T03:00:00-08:00")
      assert_off_peak(schedule, "2021-01-10T03:59:59-08:00")
      assert_off_peak(schedule, "2021-01-10T04:00:00-08:00")
      assert_off_peak(schedule, "2021-01-10T11:30:00-08:00")
      assert_off_peak(schedule, "2021-01-10T18:00:00-08:00")
      assert_off_peak(schedule, "2021-01-10T18:59:59-08:00")
      assert_off_peak(schedule, "2021-01-10T19:00:00-08:00")
      assert_off_peak(schedule, "2021-01-10T23:59:59-08:00")
    end

    it "can be set to be always on-peak" do
      schedule = described_class.new(on_peak_wday_range: 0..6, # all week
                                     on_peak_hour_range: 0..23,
                                     timezone: "America/Los_Angeles")

      # Sunday
      assert_on_peak(schedule, "2021-01-03T00:00:00-08:00")
      assert_on_peak(schedule, "2021-01-03T12:00:00-08:00")
      assert_on_peak(schedule, "2021-01-03T23:00:00-08:00")

      # Wednesday
      assert_on_peak(schedule, "2021-01-06T00:00:00-08:00")
      assert_on_peak(schedule, "2021-01-06T12:00:00-08:00")
      assert_on_peak(schedule, "2021-01-06T23:59:59-08:00")

      # Saturday
      assert_on_peak(schedule, "2021-01-09T00:00:00-08:00")
      assert_on_peak(schedule, "2021-01-09T12:00:00-08:00")
      assert_on_peak(schedule, "2021-01-09T23:59:59-08:00")
    end
  end

  def assert_on_peak(schedule, iso8601)
    expect(schedule.on_peak?(Time.iso8601(iso8601))).to eq(true)
  end

  def assert_off_peak(schedule, iso8601)
    expect(schedule.on_peak?(Time.iso8601(iso8601))).to eq(false)
  end
end
