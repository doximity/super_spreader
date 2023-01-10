# SuperSpreader

SuperSpreader is a library for massive, memory- and compute-efficient backfills of ActiveRecord models using ActiveJob.

This tool is built to backfill many millions of records in a resource-efficient way.  When paired with a properly written job, it can drastically reduce the wall time of a backfill through parallelization.  Jobs are enqueued in small batches so that the ActiveJob backend is not overwhelmed.  These jobs can also be stopped at a moment's notice, if needed.

## Example use cases

- Re-encrypt data
- Make API calls to fill in missing data
- Restructuring complex data

## Warnings

**Please be aware:** SuperSpreader is still fairly early in development.  While it can be used effecively by experienced hands, we are aware that it could have a better developer experience (DevX).  It was written to solve a specific problem (see "History").  We are working to generalize the tool as the need arises.  Pull requests are welcome!

Please also see "Roadmap" for other known limitations that may be relevant to you.

## History

SuperSpreader was originally written to re-encrypt the Dialer database, a key component of Doximity's telehealth offerings.  Without SuperSpreader, it would have taken several months to handle many millions of records using a Key Management Service (KMS) that adds an overhead of 11 ms per record.  Using SuperSpreader took the time to backfill down to a couple of weeks.  This massive backfill happened safely during very high Dialer usage during the winter of 2020.  Of course, the name came from the coronavirus pandemic, which had a number of super-spreader events in the news around the same time.  Rather than spreading disease, the SuperSpreader gem spreads out telehealth background jobs to support the healthcare professionals that fight disease.

Since that time, our team has started to use SuperSpreader in many other situations.  Our hope is that other teams, internal and external, can use it if they have similar problems to solve.

## When should I use it?

SuperSpreader was built for backfills.  If you need to touch every record and you have _a lot_ of records, it may be a good fit.

That said, it's **not** common to need a tool like SuperSpreader.  Many backfills are better handled through SQL or Rake tasks.  SuperSpreader should only be used when the additional complexity is warranted.  Before using a shiny tool, **please stop and consider the tradeoffs**.

The primary criterion to consider is whether the backfill in question is _long-running_.  If you estimate it would take at least a couple of days to complete, it makes sense to consider SuperSpreader.  Another good reason to consider this tool is _code reuse_.  If you already have Ruby-land code that would be difficult or impossible to replicate in SQL, it makes sense to use SuperSpreader, assuming the equivalent Rake task would be impractical.

## How do I use it?

TODO

## Roadmap

#### Allow for multiple concurrent backfills

Currently, SuperSpreader can only backfill using a single scheduler.  This means that only one backfill can run at a given time, which requires coordination amongst engineers.  The scheduler and configuration needs to be changed to allow for multiple concurrent backfills.

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
