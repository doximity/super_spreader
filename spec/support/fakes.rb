# frozen_string_literal: true

class FakeJob < ActiveJob::Base
end

class OtherFakeJob < ActiveJob::Base
end

class FakeModel
  def self.maximum(*)
    100
  end
end

class OtherFakeModel
  def self.maximum(*)
    200
  end
end
