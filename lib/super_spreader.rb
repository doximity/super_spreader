require "redis"

require "super_spreader/version"

require "super_spreader/peak_schedule"

module SuperSpreader
  class Error < StandardError; end
  # Your code goes here...

  def self.redis=(redis)
    @redis = redis
  end

  def self.redis
    @redis
  end
end
