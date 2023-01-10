# SuperSpreader

SuperSpreader is a library for massive, memory- and compute-efficient backfills of ActiveRecord models using ActiveJob.

This tool is built to backfill many millions of records in a resource-efficient way.  When paired with a properly written job, it can drastically reduce the wall time of a backfill through parallelization.  Jobs are enqueued in small batches so that the ActiveJob backend is not overwhelmed and can be stopped at a moment's notice, if needed.

## Example use cases

- Re-encrypt data
- Make API calls to fill in missing data
- Restructuring complex data

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'super_spreader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install super_spreader

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/super_spreader.
