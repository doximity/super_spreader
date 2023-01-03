
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "super_spreader/version"

Gem::Specification.new do |spec|
  spec.name          = "super_spreader"
  spec.version       = SuperSpreader::VERSION
  spec.authors       = ["Benjamin Oakes"]
  spec.email         = ["boakes@doximity.com"]

  spec.summary       = "ActiveJob-based backfill orchestration library"
  spec.description   = "Provides tools for managing resource-efficient backfills of large datasets via ActiveJob"
  spec.homepage      = "https://github.com/doximity/super_spreader"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/doximity/super_spreader/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
