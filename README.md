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

SuperSpreader was originally written to re-encrypt the Dialer database, a key component of Doximity's telehealth offerings.  Without SuperSpreader, it would have taken **several months** to handle many millions of records using a Key Management Service (KMS) that adds an overhead of 11 ms per record.  Using SuperSpreader took the time to backfill down to a couple of weeks.  This massive backfill happened safely during very high Dialer usage during the winter of 2020.  Of course, the name came from the coronavirus pandemic, which had a number of super-spreader events in the news around the same time.  Rather than spreading disease, the SuperSpreader gem spreads out telehealth background jobs to support the healthcare professionals that fight disease.

Since that time, our team has started to use SuperSpreader in many other situations.  Our hope is that other teams, internal and external, can use it if they have similar problems to solve.

## When should I use it?

SuperSpreader was built for backfills.  If you need to touch every record and you have _a lot_ of records, it may be a good fit.

That said, it's **not** common to need a tool like SuperSpreader.  Many backfills are better handled through SQL or Rake tasks.  SuperSpreader should only be used when the additional complexity is warranted.  Before using a shiny tool, **please stop and consider the tradeoffs**.

The primary criterion to consider is whether the backfill in question is _long-running_.  If you estimate it would take at least a couple of days to complete, it makes sense to consider SuperSpreader.  Another good reason to consider this tool is _code reuse_.  If you already have Ruby-land code that would be difficult or impossible to replicate in SQL, it makes sense to use SuperSpreader, assuming the equivalent Rake task would be impractical.

## How does it work?

SuperSpreader enqueues a configurable number of background jobs on a set schedule.  These background jobs are executed in small batches such that only a small number of jobs are enqueued at any given time.  The jobs start at the most recent record and work back to the first record, based on the auto-incrementing primary key.

The configuration is able to be tuned for the needs of an individual problem.  If the backfill would require months of compute time, it can be run in parallel so that it takes much less time.  The resource utilization can be spread out so that shared resources, such as a database, are not overwhelmed with requests.  Finally, there is also support for running more jobs during off-peak usage based on a schedule.

Backfills are implemented using ActiveJob classes.  SuperSpreader orchestrates running those jobs.  Each set of jobs is enqueued by a scheduler using the supplied configuration.

As an example, assume that there's a table with 100,000,000 rows which need Ruby-land logic to be applied using `ExampleBackfillJob`.  The rate (e.g., how many jobs per second) is configurable.  Once configured, SuperSpreader would enqueue job in batches like:

    ExampleBackfillJob run_at: "2020-11-16T22:51:59Z", begin_id: 99_999_901, end_id: 100_000_000
    ExampleBackfillJob run_at: "2020-11-16T22:51:59Z", begin_id: 99_999_801, end_id:  99_999_900
    ExampleBackfillJob run_at: "2020-11-16T22:51:59Z", begin_id: 99_999_701, end_id:  99_999_800
    ExampleBackfillJob run_at: "2020-11-16T22:52:00Z", begin_id: 99_999_601, end_id:  99_999_700
    ExampleBackfillJob run_at: "2020-11-16T22:52:00Z", begin_id: 99_999_501, end_id:  99_999_600
    ExampleBackfillJob run_at: "2020-11-16T22:52:00Z", begin_id: 99_999_401, end_id:  99_999_500

Notice that there are 3 jobs per second, 2 seconds of work were enqueued, and the batch size is 100.  Again, this is just an example for illustration, and the configuration can be modified to suit the needs of the problem.

After running out of work, SuperSpreader will enqueue more work:

    SuperScheduler::SchedulerJob run_at: "2020-11-16T22:52:01Z"

And the work continues:

    ExampleBackfillJob run_at: "2020-11-16T22:52:01Z", begin_id: 99_999_401, end_id:  99_999_500
    ExampleBackfillJob run_at: "2020-11-16T22:52:01Z", begin_id: 99_999_301, end_id:  99_999_400
    ExampleBackfillJob run_at: "2020-11-16T22:52:01Z", begin_id: 99_999_201, end_id:  99_999_300
    ExampleBackfillJob run_at: "2020-11-16T22:52:02Z", begin_id: 99_999_101, end_id:  99_999_200
    ExampleBackfillJob run_at: "2020-11-16T22:52:02Z", begin_id: 99_999_001, end_id:  99_999_100
    ExampleBackfillJob run_at: "2020-11-16T22:52:02Z", begin_id: 99_998_901, end_id:  99_999_000

This process continues until there is no more work to be done.  For more detail, please see [Spreader](https://github.com/doximity/super_spreader/blob/master/lib/super_spreader/spreader.rb) and [its spec](https://github.com/doximity/super_spreader/blob/master/spec/spreader_spec.rb).

Additionally, the configuration can be tuned while SuperSpreader is running.  The configuration is read each time `SchedulerJob` runs.  Does the process need to go faster?  Increase the number of jobs per second.  Are batches taking too long to complete?  Decrease the batch size.  Is `SchedulerJob` taking a long time to complete?  Decrease the duration so that less work is enqueued in each cycle.  Finally, SuperSpreader can be stopped instantly and resumed at a later time, if a need ever arises.

As it stands, each run of SuperSpreader is hand-tuned.  It is highly recommended that SuperSpreader resource utilization is monitored during runs.  That said, it is designed to run autonomously once a good configuration is found.

## How do I use it?

To repeat an earlier disclaimer:

> **Please be aware:** SuperSpreader is still fairly early in development.  While it can be used effecively by experienced hands, we are aware that it could have a better developer experience (DevX).  It was written to solve a specific problem (see "History").  We are working to generalize the tool as the need arises.  Pull requests are welcome!

If you haven't yet, please read the "How does it work?" section.  This basic workflow is tested in `spec/integration/backfill_spec.rb`.

First, write a backfill job.  Please see [this example for details](https://github.com/doximity/super_spreader/blob/master/spec/support/example_backfill_job.rb).

Next, configure `SuperSpreader` from the console by saving `SchedulerConfig` to Redis.  For documentation on each attribute, please see [SchedulerConfig](https://github.com/doximity/super_spreader/blob/master/lib/super_spreader/scheduler_config.rb).  It is recommended that you start slow, with small batches, short durations, and low per-second rates.

**Important:** SuperSpreader currently only supports a _single_ configuration, though removing that limitation is our Roadmap (please see below).

```ruby
# NOTE: This is an example.  You should take your situation into account when
# setting these values.
config = SuperSpreader::SchedulerConfig.new

config.batch_size = 10
config.duration = 10
config.job_class_name = "ExampleBackfillJob"

config.per_second_on_peak = 3.0
config.per_second_off_peak = 3.0

config.on_peak_timezone = "America/Los_Angeles"
config.on_peak_wday_begin = 1
config.on_peak_wday_end = 5
config.on_peak_hour_begin = 5
config.on_peak_hour_end = 17

config.save
```

Now the `SchedulerJob` can be started.  It will run until it is stopped or runs out of work.

```ruby
SuperSpreader::SchedulerJob.perform_now
```

At this point, you should monitor your database and worker instances using the tooling you have available.  You should make adjustments based on the metrics you have available.

Based on those metrics, slowly step up `per_second_on_peak` and `batch_size` while continuing to monitor:

```ruby
config.batch_size = 20
config.save
```

```ruby
config.per_second_on_peak = 4.0
config.save
```

Continue to step up the rates, until you arrive at a rate that is acceptable for your situation.
For our re-encryption project as an example, our jobs ran at this rate:

```ruby
# NOTE: This is an example.  You should take your situation into account when
# setting these values.
config = SuperSpreader::SchedulerConfig.new

config.batch_size = 70
config.duration = 180
config.job_class_name = "ReencryptJob"

config.per_second_on_peak = 3.0
config.per_second_off_peak = 7.5

config.on_peak_timezone = "America/Los_Angeles"
config.on_peak_wday_begin = 1
config.on_peak_wday_end = 5
config.on_peak_hour_begin = 5
config.on_peak_hour_end = 17

config.save
```

### Disaster recovery

If at any point you need to stop the background jobs, stop all scheduling using:

```ruby
SuperSpreader::SchedulerJob.stop!
```

Optionally, if it is acceptable to have a partially-processed cycle, you can stop the backfill jobs as well:

```ruby
ExampleBackfillJob.stop!
```

(Recovering from a partially-processed cycle requires manually setting the correct `initial_id` in `SpreadTracker`.)

The jobs will still be present in the job runner, but will all execute instantly because of the early return as demonstrated in [the example job](https://github.com/doximity/super_spreader/blob/master/spec/support/example_backfill_job.rb).  After the last scheduler job, the process will be paused.

## Installation

If you've gotten this far and think SuperSpreader is a good fit for your problem, these are the instructions for installing it.

Add this line to your application's Gemfile:

```ruby
gem 'super_spreader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install super_spreader

SuperSpreader requires an ActiveRecord-compatible database, an ActiveJob-compatible job runner, and Redis for bookkeeping.

For Rails, please set up SuperSpreader using an initializer:

```ruby
# config/initializers/super_spreader.rb

SuperSpreader.logger = Rails.logger
SuperSpreader.redis = Redis.new(url: ENV["REDIS_URL"])
```

## Roadmap

This is a rough outline of some ideas we are considering implementing, based on the content in this README.

#### Add end time estimate

Add a feature to estimate when the last ID will be processed, which is useful to know when tuning the execution of the scheduler.

#### Allow for multiple concurrent backfills

Currently, SuperSpreader can only backfill using a single scheduler.  This means that only one backfill can run at a given time, which requires coordination amongst engineers.  The scheduler and configuration needs to be changed to allow for multiple concurrent backfills.

#### Monitoring

This document refers to external tooling for monitoring resource usage.  Add instrumentation hooks to allow for internal monitoring.

#### Automated tuning based on backpressure

After adding internal monitoring, we could automate discovery of optimal `batch_size` and `per_second` values, given recommended tolerances such as 100 ms for backfill jobs and 1500 ms for the scheduler.  This would be a significant improvement in DevX.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. See [CONTRIBUTING.md](./CONTRIBUTING.md)
2. Fork it ( https://github.com/doximity/super_spreader/fork )
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## License

`super_spreader` is licensed under an Apache 2 license. Contributors are required to sign an contributor license agreement. See LICENSE.txt and CONTRIBUTING.md for more information.
