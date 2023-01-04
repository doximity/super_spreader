# frozen_string_literal: true

require "super_spreader/spread_tracker"

module SuperSpreader
  class Spreader
    def initialize(job_class, model_class, spread_tracker: nil)
      @job_class = job_class
      @model_class = model_class
      @spread_tracker = spread_tracker || SuperSpreader::SpreadTracker.new(job_class, model_class)
    end

    def spread(batch_size:, duration:, per_second:, initial_id:, begin_at: Time.now.utc)
      end_id = initial_id
      segment_duration = 1.0 / per_second
      time_index = 0.0
      batches = []

      while time_index < duration
        break if end_id <= 0

        # Use floor to prevent subsecond times
        run_at = begin_at + time_index.floor
        begin_id = clamp(end_id - batch_size + 1)
        batches << { run_at: run_at, begin_id: begin_id, end_id: end_id }

        break if begin_id == 1

        end_id = begin_id - 1
        time_index += segment_duration
      end

      batches
    end

    def enqueue_spread(**opts)
      initial_id = @spread_tracker.initial_id
      return if initial_id.zero?

      batches = spread(**opts.merge(initial_id: initial_id))

      batches.each do |batch|
        @job_class.
          set(wait_until: batch[:run_at]).
          perform_later(batch[:begin_id], batch[:end_id])
      end

      last_begin_id = batches.last[:begin_id]
      @spread_tracker.initial_id = last_begin_id - 1
    end

    private

    def clamp(value)
      value <= 0 ? 1 : value
    end
  end
end
