# frozen_string_literal: true

# This class is an example job that uses the interface that SuperSpreader
# expects.  While this job is for backfilling as an example, any problem
# that can be subdivided into small batches can be implemented.
#
# In Rails, your class should be located within under `app/jobs/` and should
# inherit from `ApplicationJob`.
class ExampleBackfillJob < ActiveJob::Base
  # This provides support for stopping the job in an emergency.  Optional, but
  # highly recommended.
  extend SuperSpreader::StopSignal

  # This is the model class that will be used when tracking the spread of jobs.
  # It is expected to be an ActiveRecord class.
  def self.super_spreader_model_class
    ExampleModel
  end

  # Batches are executed using this method and are expected to update all IDs
  # in the given range.
  def perform(begin_id, end_id)
    # This line is what makes it possible to stop all instances of the job
    # using `ExampleBackfillJob.stop!`.  Optional, but highly recommended.
    return if self.class.stopped?

    # In a real application, this section would make use appropriate, efficient
    # database queries.
    #
    # Using SuperSpreader isn't a replacement for efficient SQL.  Please
    # research options such as https://github.com/zdennis/activerecord-import.
    ExampleModel.where(id: begin_id..end_id).each do |example_model|
      example_model.update(example_attribute: "example value")
    end
  end
end
