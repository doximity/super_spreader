require "bundler/setup"

require "active_job"
require "active_support/testing/time_helpers"
require "factory_bot"
require "pry"
require "rspec/rails/matchers"

require "super_spreader"
require "factories/scheduler_config"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ActiveSupport::Testing::TimeHelpers
  config.include FactoryBot::Syntax::Methods
  config.include RSpec::Rails::Matchers

  config.before :suite do
    SuperSpreader.logger = Logger.new(StringIO.new)
    SuperSpreader.redis = Redis.new(url: ENV["REDIS_URL"])
    ActiveJob::Base.queue_adapter = :test
  end

  config.before do
    SuperSpreader.redis.flushall
  end

  # Borrowed from rspec-rails
  #
  # https://github.com/rspec/rspec-rails/blob/c60ff7907559653cd9d1ec1a6113bf86c9359fab/spec/rspec/rails/matchers/active_job_spec.rb#L38-L43
  config.around do |example|
    original_logger = ActiveJob::Base.logger
    ActiveJob::Base.logger = Logger.new(nil) # Silence messages "[ActiveJob] Enqueued ...".
    example.run
    ActiveJob::Base.logger = original_logger
  end
end
