# frozen_string_literal: true

require "spec_helper"

RSpec.describe SuperSpreader::StopSignal do
  it "has a lifecycle that allows stopping a job" do
    # Default
    expect(StopSignalFakeJob.stopped?).to eq(false)

    StopSignalFakeJob.stop!

    expect(StopSignalFakeJob.stopped?).to eq(true)

    # Idempotent
    StopSignalFakeJob.stop!

    expect(StopSignalFakeJob.stopped?).to eq(true)

    StopSignalFakeJob.go!

    expect(StopSignalFakeJob.stopped?).to eq(false)

    # Idempotent
    StopSignalFakeJob.go!

    expect(StopSignalFakeJob.stopped?).to eq(false)
  end

  class StopSignalFakeJob
    extend SuperSpreader::StopSignal
  end
end
