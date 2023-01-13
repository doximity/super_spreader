# frozen_string_literal: true

require "spec_helper"

RSpec.describe SuperSpreader do
  it "has a version number" do
    expect(SuperSpreader::VERSION).not_to be nil
  end
end
