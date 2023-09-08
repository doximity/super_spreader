require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)
YARD::Rake::YardocTask.new(:doc)

task default: :spec

desc "Run a REPL with access to this library"
task :console do
  sh("irb -I lib -r super_spreader")
end

namespace :check do
  desc "Run all checks"
  task all: %i[redis]

  desc "Confirm Redis is accessible"
  task :redis do
    require "redis"

    inaccessible_error_message = "Redis: inaccessible (please confirm that a Redis server is installed and running, e.g. redis-server)"

    redis = Redis.new(url: ENV["REDIS_URL"])

    if redis.ping == "PONG"
      puts "Redis: OK"
    else
      raise inaccessible_error_message
    end
  rescue Redis::CannotConnectError
    raise inaccessible_error_message
  end
end
