# frozen_string_literal: true

require "spec_helper"
require "super_spreader_scheduler_config"

RSpec.describe SuperSpreaderSchedulerConfig do
  describe "#per_second" do
    it "chooses on peak vs off peak rates" do
      config = build(:super_spreader_scheduler_config,
                     per_second_on_peak: 3.0,
                     per_second_off_peak: 9.0)

      config.schedule = double(on_peak?: true)
      expect(config.per_second).to eq(3.0)

      config.schedule = double(on_peak?: false)
      expect(config.per_second).to eq(9.0)
    end

    it "has default arguments" do
      config = build(:super_spreader_scheduler_config)

      expect(config.per_second).to be > 0.0
    end
  end
end
