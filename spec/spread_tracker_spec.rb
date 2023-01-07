# frozen_string_literal: true

require "spec_helper"
require "support/fakes"

RSpec.describe SuperSpreader::SpreadTracker do
  it "has a default initial_id" do
    spread_tracker = build_spread_tracker

    expect(spread_tracker.initial_id)
      .to eq(FakeModel100.maximum(:id))
  end

  it "allows setting the initial_id" do
    spread_tracker = build_spread_tracker

    spread_tracker.initial_id = 1

    expect(spread_tracker.initial_id).to eq(1)
  end

  it "allows clearing the initial_id" do
    spread_tracker = build_spread_tracker

    spread_tracker.initial_id = nil

    expect(spread_tracker.initial_id)
      .to eq(FakeModel100.maximum(:id))
  end

  it "supports tracking multiple models" do
    spread_tracker = described_class.new(FakeJob, FakeModel100)
    other_spread_tracker = described_class.new(FakeJob, FakeModel200)

    spread_tracker.initial_id = 99
    other_spread_tracker.initial_id = 199

    expect(spread_tracker.initial_id).to eq(99)
    expect(other_spread_tracker.initial_id).to eq(199)
  end

  it "supports tracking multiple jobs" do
    spread_tracker = described_class.new(FakeJob, FakeModel100)
    other_spread_tracker = described_class.new(OtherFakeJob, FakeModel100)

    spread_tracker.initial_id = 99
    other_spread_tracker.initial_id = 199

    expect(spread_tracker.initial_id).to eq(99)
    expect(other_spread_tracker.initial_id).to eq(199)
  end

  def build_spread_tracker
    described_class.new(FakeJob, FakeModel100)
  end
end
