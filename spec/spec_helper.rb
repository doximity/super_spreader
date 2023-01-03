require "bundler/setup"
require "super_spreader"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    SuperSpreader.redis = Redis.new(url: ENV["REDIS_URL"])
  end

  config.before do
    SuperSpreader.redis.flushall
  end
end
