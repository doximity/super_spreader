# frozen_string_literal: true

require "active_job"
require "spec_helper"

RSpec.describe SuperSpreader::Spreader do
  it "has a default begin_at value" do
    batches = spread(batch_size: 5, duration: 30, per_second: 1, initial_id: 20)

    expect(batches.length).to eq(4)
  end

  it "spreads in equal-sized batches of 5 records per second" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)

    batches = spread(batch_size: 5, duration: 30, per_second: 1, initial_id: 20, begin_at: begin_at)

    expected_batches = [
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 16, end_id: 20 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 11, end_id: 15 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 6,  end_id: 10 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  2), begin_id: 1,  end_id: 5  }
    ]

    expect(batches).to eq(expected_batches)
  end

  it "spreads in equal-sized batches of 5 records per second, clamping the final run of two records" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)

    batches = spread(batch_size: 5, duration: 30, per_second: 1, initial_id: 22, begin_at: begin_at)

    expected_batches = [
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 18, end_id: 22 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 13, end_id: 17 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 8,  end_id: 12 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  2), begin_id: 3,  end_id: 7  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  3), begin_id: 1,  end_id: 2  }
    ]

    expect(batches).to eq(expected_batches)
  end

  it "spreads in equal-sized batches of 5 records per second, clamping the final single-record run" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)

    batches = spread(batch_size: 5, duration: 30, per_second: 1, initial_id: 21, begin_at: begin_at)

    expected_batches = [
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 17, end_id: 21 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 12, end_id: 16 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 7,  end_id: 11 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  2), begin_id: 2,  end_id: 6  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  3), begin_id: 1,  end_id: 1  }
    ]

    expect(batches).to eq(expected_batches)
  end

  it "spreads with multiple batches per second" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)

    batches = spread(batch_size: 100, duration: 30, per_second: 3, initial_id: 1000, begin_at: begin_at)

    expected_batches = [
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 901, end_id: 1000 },
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 801, end_id: 900  },
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 701, end_id: 800  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 601, end_id: 700  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 501, end_id: 600  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 401, end_id: 500  },
      # Presumably, IEEE 754 floating point causes this an extra batch on
      # second 0 even though it should probably be a 1.  Not a big deal in this
      # case.
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 301, end_id: 400  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 201, end_id: 300  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 101, end_id: 200  },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  2), begin_id: 1,   end_id: 100  }
    ]

    expect(batches).to eq(expected_batches)
  end

  it "only spreads over the specified duration, even if other IDs remain" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)

    batches = spread(batch_size: 100, duration: 3, per_second: 3, initial_id: 1999, begin_at: begin_at)

    expected_batches = [
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 1900, end_id: 1999 },
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 1800, end_id: 1899 },
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 1700, end_id: 1799 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 1600, end_id: 1699 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 1500, end_id: 1599 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 1400, end_id: 1499 },
      # Presumably, IEEE 754 floating point causes this an extra batch on
      # second 0 even though it should probably be a 1.  Not a big deal in this
      # case.
      { run_at: Time.utc(2020, 11, 16, 22, 52,  0), begin_id: 1300, end_id: 1399 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 1200, end_id: 1299 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 1100, end_id: 1199 }
    ]

    expect(batches).to eq(expected_batches)
  end

  it "spreads over a fractional per_second value" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)

    batches = spread(batch_size: 100, duration: 10, per_second: 0.5, initial_id: 1999, begin_at: begin_at)

    expected_batches = [
      { run_at: Time.utc(2020, 11, 16, 22, 51, 59), begin_id: 1900, end_id: 1999 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  1), begin_id: 1800, end_id: 1899 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  3), begin_id: 1700, end_id: 1799 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  5), begin_id: 1600, end_id: 1699 },
      { run_at: Time.utc(2020, 11, 16, 22, 52,  7), begin_id: 1500, end_id: 1599 }
    ]

    expect(batches).to eq(expected_batches)
  end

  it "does not enqueue if initial_id is 0" do
    spread_tracker = instance_double(FakeSpreadTracker, initial_id: 0)
    super_spreader = described_class.new(FakeJob, FakeModel, spread_tracker: spread_tracker)

    next_id = super_spreader.enqueue_spread(batch_size: 2, duration: 3, per_second: 1)

    expect(FakeJob).not_to have_been_enqueued
    expect(next_id).to eq(0)
    expect(spread_tracker.initial_id).to eq(0)
  end

  it "accepts the same arguments as spread when enqueuing" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)
    spread_tracker = FakeSpreadTracker.new(10)
    super_spreader = described_class.new(FakeJob, FakeModel, spread_tracker: spread_tracker)

    next_id = super_spreader.enqueue_spread(batch_size: 2, duration: 3, per_second: 1, begin_at: begin_at)

    expect(FakeJob).to have_been_enqueued.at(Time.utc(2020, 11, 16, 22, 51, 59)).with(9, 10)
    expect(FakeJob).to have_been_enqueued.at(Time.utc(2020, 11, 16, 22, 52,  0)).with(7,  8)
    expect(FakeJob).to have_been_enqueued.at(Time.utc(2020, 11, 16, 22, 52,  1)).with(5,  6)
    expect(next_id).to eq(4)
    expect(spread_tracker.initial_id).to eq(4)
  end

  it "sets initial_id to 0 on last run" do
    begin_at = Time.utc(2020, 11, 16, 22, 51, 59)
    spread_tracker = FakeSpreadTracker.new(4)
    super_spreader = described_class.new(FakeJob, FakeModel, spread_tracker: spread_tracker)

    next_id = super_spreader.enqueue_spread(batch_size: 2, duration: 3, per_second: 1, begin_at: begin_at)

    expect(FakeJob).to have_been_enqueued.at(Time.utc(2020, 11, 16, 22, 51, 59)).with(3, 4)
    expect(FakeJob).to have_been_enqueued.at(Time.utc(2020, 11, 16, 22, 52, 0)).with(1, 2)
    expect(next_id).to eq(0)
    expect(spread_tracker.initial_id).to eq(0)
  end

  def spread(...)
    described_class.new(FakeJob, FakeModel).spread(...)
  end

  class FakeJob < ActiveJob::Base
  end

  class FakeModel
  end

  FakeSpreadTracker = Struct.new(:initial_id)
end
