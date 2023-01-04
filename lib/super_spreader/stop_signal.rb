# frozen_string_literal: true

require "redis"

module SuperSpreader
  module StopSignal
    def stop!
      redis.set(stop_key, true)
    end

    def go!
      redis.del(stop_key)
    end

    def stopped?
      redis.exists(stop_key).positive?
    end

    private

    def redis
      SuperSpreader.redis
    end

    def stop_key
      "#{name}:stop"
    end
  end
end
