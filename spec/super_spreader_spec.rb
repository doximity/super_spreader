# frozen_string_literal: true

require "spec_helper"

RSpec.describe SuperSpreader do
  it "has a version number" do
    expect(SuperSpreader::VERSION).not_to be nil
  end

  it "allows referencing StopSignal while transitioning to TrackBallast::StopSignal" do
    expect(SuperSpreader::StopSignal).to be TrackBallast::StopSignal
  end
end
