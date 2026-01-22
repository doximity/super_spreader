# frozen_string_literal: true

require "redis"

module SuperSpreader
  # @deprecated Please use TrackBallast::StopSignal instead
  module StopSignal
    # @deprecated Please use {TrackBallast::StopSignal.stop!} instead
    def stop!
      warn "DEPRECATION WARNING: the class SuperSpreader::StopSignal is deprecated and will be removed in v1.0. " \
        "Use TrackBallast::StopSignal instead."
      redis.set(stop_key, true)
    end

    # @deprecated Please use {TrackBallast::StopSignal.go!} instead
    def go!
      redis.del(stop_key)
    end

    # @deprecated Please use {TrackBallast::StopSignal.stopped?} instead
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
