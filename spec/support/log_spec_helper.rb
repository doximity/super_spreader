# frozen_string_literal: true

require "stringio"

module LogSpecHelper
  def capture_log
    original_logger = SuperSpreader.logger
    fake_log_device = StringIO.new
    SuperSpreader.logger = ActiveSupport::TaggedLogging.new(Logger.new(fake_log_device))

    yield

    fake_log_device.rewind
    fake_log_device.read
  ensure
    SuperSpreader.logger = original_logger
  end
end
