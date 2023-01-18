# frozen_string_literal: true

require "active_job"
require "spec_helper"
require "support/example_backfill_job"
require "support/log_spec_helper"

RSpec.describe "Integration" do
  include LogSpecHelper

  it "can backfill using an example job" do
    create_list(:example_model, 1000)

    config = SuperSpreader::SchedulerConfig.new

    config.batch_size = 10
    config.duration = 10
    config.job_class_name = "ExampleBackfillJob"

    config.per_second_on_peak = 3.0
    config.per_second_off_peak = 7.5

    config.on_peak_timezone = "America/Los_Angeles"
    config.on_peak_wday_begin = 1
    config.on_peak_wday_end = 5
    config.on_peak_hour_begin = 5
    config.on_peak_hour_end = 17

    config.save

    expect(SuperSpreader::SchedulerConfig.new.serializable_hash)
      .to eq({
        "batch_size" => 10,
        "duration" => 10,
        "job_class_name" => "ExampleBackfillJob",
        "on_peak_hour_begin" => 5,
        "on_peak_hour_end" => 17,
        "on_peak_timezone" => "America/Los_Angeles",
        "on_peak_wday_begin" => 1,
        "on_peak_wday_end" => 5,
        "per_second_off_peak" => 7.5,
        "per_second_on_peak" => 3.0
      })

    log = capture_log do
      perform_enqueued_jobs do
        SuperSpreader::SchedulerJob.perform_now
      end
    end

    # NOTE: There might be some extra runs of `SchedulerJob` at the end of the
    # log, but it's unclear whether that's because of `perform_enqueued_jobs`.
    # In any case, it's benign.
    expect(log.lines.length).to eq(7)
    example_backfill_models = ExampleModel.where(id: 1..1000)
    expect(example_backfill_models.length).to eq(1000)
    expect(example_backfill_models.all? { |m| m.example_attribute.present? }).to eq(true)
  end

  it "can backfill using a manually-set initial_id" do
    create_list(:example_model, 1000)

    config = SuperSpreader::SchedulerConfig.new

    config.batch_size = 10
    config.duration = 10
    config.job_class_name = "ExampleBackfillJob"

    config.per_second_on_peak = 3.0
    config.per_second_off_peak = 7.5

    config.on_peak_timezone = "America/Los_Angeles"
    config.on_peak_wday_begin = 1
    config.on_peak_wday_end = 5
    config.on_peak_hour_begin = 5
    config.on_peak_hour_end = 17

    config.save

    expect(SuperSpreader::SchedulerConfig.new.serializable_hash)
      .to eq({
        "batch_size" => 10,
        "duration" => 10,
        "job_class_name" => "ExampleBackfillJob",
        "on_peak_hour_begin" => 5,
        "on_peak_hour_end" => 17,
        "on_peak_timezone" => "America/Los_Angeles",
        "on_peak_wday_begin" => 1,
        "on_peak_wday_end" => 5,
        "per_second_off_peak" => 7.5,
        "per_second_on_peak" => 3.0
      })

    tracker = SuperSpreader::SpreadTracker.new(ExampleBackfillJob, ExampleModel)
    tracker.initial_id = 500

    perform_enqueued_jobs do
      SuperSpreader::SchedulerJob.perform_now
    end

    processed_models = ExampleModel.where(id: 1..500)
    expect(processed_models.length).to eq(500)
    expect(processed_models.all? { |m| m.example_attribute.present? }).to eq(true)
    unprocessed_models = ExampleModel.where(id: 501..1000)
    expect(unprocessed_models.length).to eq(500)
    expect(unprocessed_models.all? { |m| m.example_attribute.present? }).to eq(false)
  end

  describe ExampleBackfillJob do
    it "has SuperSpreader support" do
      expect(described_class.model_class).to eq(ExampleModel)
    end

    it "sets values on instances" do
      example_model_1 = create(:example_model)
      example_model_2 = create(:example_model)

      described_class.perform_now(example_model_1.id, example_model_2.id)
      example_model_1.reload
      example_model_2.reload

      expect(example_model_1.example_attribute).to be_present
      expect(example_model_2.example_attribute).to be_present
    end

    it "can be stopped" do
      example_model_1 = create(:example_model)
      example_model_2 = create(:example_model)

      described_class.stop!
      described_class.perform_now(example_model_1.id, example_model_2.id)

      expect(described_class).to be_stopped
      expect(example_model_1.example_attribute).not_to be_present
      expect(example_model_2.example_attribute).not_to be_present
    end
  end
end
