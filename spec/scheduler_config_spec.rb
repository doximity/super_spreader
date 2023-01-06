# frozen_string_literal: true

require "spec_helper"

RSpec.describe SuperSpreader::SchedulerConfig do
  describe "#per_second" do
    it "chooses on peak vs off peak rates" do
      config = build(:scheduler_config,
        per_second_on_peak: 3.0,
        per_second_off_peak: 9.0)

      config.schedule = instance_double(SuperSpreader::PeakSchedule, on_peak?: true)
      expect(config.per_second).to eq(3.0)

      config.schedule = instance_double(SuperSpreader::PeakSchedule, on_peak?: false)
      expect(config.per_second).to eq(9.0)
    end

    it "has default arguments" do
      config = build(:scheduler_config)

      expect(config.per_second).to be > 0.0
    end
  end
end
