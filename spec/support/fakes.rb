# frozen_string_literal: true

require "active_job"

class FakeJob < ActiveJob::Base
end

class OtherFakeJob < ActiveJob::Base
end

class FakeModel
end

class FakeModel100
  def self.maximum(*)
    100
  end
end

class FakeModel200
  def self.maximum(*)
    200
  end
end

FakeSpreadTracker = Struct.new(:initial_id)
