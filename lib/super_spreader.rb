# frozen_string_literal: true

require "super_spreader/version"
require "super_spreader/peak_schedule"
require "super_spreader/redis_model"
require "super_spreader/scheduler_config"
require "super_spreader/scheduler_job"
require "super_spreader/spread_tracker"
require "super_spreader/spreader"
require "super_spreader/stop_signal"

module SuperSpreader
  class Error < StandardError; end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  def self.redis=(redis)
    @redis = redis
  end

  def self.redis
    @redis
  end
end
