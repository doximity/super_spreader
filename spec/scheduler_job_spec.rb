# frozen_string_literal: true

require "spec_helper"
require "support/log_spec_helper"
require "super_spreader/scheduler_job"

RSpec.describe SuperSpreader::SchedulerJob do
  include LogSpecHelper

  before do
    ExampleModelClass.reset!
  end

  describe "#perform" do
    it "does nothing if stopped" do
      described_class.stop!

      expect(described_class.perform_now).to eq(nil)
    end

    it "enqueues reencrypt jobs as configured" do
      ExampleModelClass.create
      create(:scheduler_config,
             batch_size: 80,
             duration: 3600,
             per_second_on_peak: 3,
             per_second_off_peak: 3,
             job_class_name: "ExampleJob")

      travel_to(Time.new(2020, 12, 16, 0, 0, 0, 0)) do
        log = capture_log do
          described_class.perform_now
        end

        # FIXME: {"subject":"SuperSpreader::SchedulerJob","started_at":"2020-12-16T00:00:00Z"}
        expect(log).to eq(<<~LOG)
          {"subject":"SuperSpreader::SchedulerJob","started_at":"2020-12-15T18:00:00-06:00"}
          {"subject":"SuperSpreader::SchedulerJob","batch_size":80,"duration":3600,"job_class_name":"ExampleJob","per_second_on_peak":3.0,"per_second_off_peak":3.0,"on_peak_timezone":"America/Los_Angeles","on_peak_hour_begin":5,"on_peak_hour_end":17,"on_peak_wday_begin":1,"on_peak_wday_end":5}
          {"subject":"SuperSpreader::SchedulerJob","next_id":0}
        LOG

        expect(described_class).not_to have_been_enqueued
      end
    end

    it "enqueues another run if there is more to process" do
      next_model = ExampleModelClass.create
      ExampleModelClass.create
      create(:scheduler_config,
             batch_size: 1,
             duration: 1,
             per_second_on_peak: 1,
             per_second_off_peak: 1,
             job_class_name: "ExampleJob")

      travel_to(Time.new(2020, 12, 16, 0, 0, 0, 0)) do
        log = capture_log do
          described_class.perform_now
        end

        # FIXME: {"subject":"SuperSpreader::SchedulerJob","started_at":"2020-12-16T00:00:00Z"}
        # FIXME: {"subject":"SuperSpreader::SchedulerJob","next_run_at":"2020-12-16T00:00:01.000Z"}
        expect(log).to eq(<<~LOG)
          {"subject":"SuperSpreader::SchedulerJob","started_at":"2020-12-15T18:00:00-06:00"}
          {"subject":"SuperSpreader::SchedulerJob","batch_size":1,"duration":1,"job_class_name":"ExampleJob","per_second_on_peak":1.0,"per_second_off_peak":1.0,"on_peak_timezone":"America/Los_Angeles","on_peak_hour_begin":5,"on_peak_hour_end":17,"on_peak_wday_begin":1,"on_peak_wday_end":5}
          {"subject":"SuperSpreader::SchedulerJob","next_id":#{next_model.id}}
          {"subject":"SuperSpreader::SchedulerJob","next_run_at":"2020-12-15T18:00:01-06:00"}
        LOG

        expect(described_class).to have_been_enqueued
      end
    end
  end

  describe "#next_run_at" do
    it "is the configured amount of time in the future" do
      travel_to(Time.new(2020, 12, 16, 0, 0, 0, 0)) do
        SuperSpreader::SchedulerConfig.new(duration: 3600).save

        expected_time = Time.new(2020, 12, 16, 1, 0, 0, 0)
        expect(described_class.new.next_run_at).to eq(expected_time)
      end
    end
  end

  class ExampleModelClass
    attr_reader :id

    def initialize(id:)
      @id = id
    end

    def self.create
      increment_maximum

      new(id: maximum)
    end

    def self.reset!
      @maximum = 0
    end

    def self.maximum(*)
      @maximum
    end

    def self.increment_maximum
      @maximum += 1
    end
  end

  class ExampleJob < ActiveJob::Base
    def self.model_class
      ExampleModelClass
    end
  end
end
