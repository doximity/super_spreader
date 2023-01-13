# frozen_string_literal: true

require "spec_helper"

RSpec.describe SuperSpreader::StopSignal do
  it "has a lifecycle that allows stopping a job" do
    fake_job = Class.new do
      extend SuperSpreader::StopSignal
    end

    # Default
    expect(fake_job.stopped?).to eq(false)

    fake_job.stop!

    expect(fake_job.stopped?).to eq(true)

    # Idempotent
    fake_job.stop!

    expect(fake_job.stopped?).to eq(true)

    fake_job.go!

    expect(fake_job.stopped?).to eq(false)

    # Idempotent
    fake_job.go!

    expect(fake_job.stopped?).to eq(false)
  end
end
