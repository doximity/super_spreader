# frozen_string_literal: true

module ActiveJobHelper
  def with_test_adapter(separate_default_and_outage_adapter: false)
    original_adapter = ActiveJob::Base.queue_adapter

    # see: https://github.com/rails/rails/blob/v6.1.4.1/activejob/lib/active_job/queue_adapter.rb#L40
    test_adapter = ActiveJob::QueueAdapters.lookup(:test).new

    ActiveJob::Base.queue_adapter = test_adapter

    begin
      yield
    ensure
      ActiveJob::Base.queue_adapter = original_adapter
    end
  end
end
