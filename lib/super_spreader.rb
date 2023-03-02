# frozen_string_literal: true

require "super_spreader/version"

require "super_spreader/batch_helper"
require "super_spreader/peak_schedule"
require "super_spreader/redis_model"
require "super_spreader/scheduler_config"
require "super_spreader/scheduler_job"
require "super_spreader/spread_tracker"
require "super_spreader/spreader"
require "super_spreader/stop_signal"

module SuperSpreader
  class Error < StandardError; end

  class << self
    attr_accessor :logger, :redis
  end
end
