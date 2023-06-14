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
