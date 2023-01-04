require "redis"

require "super_spreader/version"

require "super_spreader/peak_schedule"

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
