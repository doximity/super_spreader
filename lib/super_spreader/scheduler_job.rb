# frozen_string_literal: true

require "json"
require "super_spreader/scheduler_config"
require "super_spreader/spreader"
require "super_spreader/stop_signal"

module SuperSpreader
  class SchedulerJob < ActiveJob::Base
    extend SuperSpreader::StopSignal

    def perform
      return if self.class.stopped?

      log(started_at: Time.current.iso8601)
      log(config.serializable_hash)

      super_spreader = SuperSpreader::Spreader.new(*config.super_spreader_config)
      next_id = super_spreader.enqueue_spread(config.spread_options)
      log(next_id: next_id)

      return if next_id.zero?

      self.class.set(wait_until: next_run_at).perform_later
      log(next_run_at: next_run_at.iso8601)
    end

    def next_run_at
      config.duration.seconds.from_now
    end

    def config
      @config ||= SuperSpreader::SchedulerConfig.new
    end

    private

    def log(hash)
      SuperSpreader.logger.info({ subject: self.class.name }.merge(hash).to_json)
    end
  end
end
