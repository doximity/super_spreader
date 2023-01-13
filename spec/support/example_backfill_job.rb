# frozen_string_literal: true

class ExampleBackfillJob < ActiveJob::Base
  extend SuperSpreader::StopSignal

  def self.model_class
    ExampleModel
  end

  def perform(begin_id, end_id)
    return if self.class.stopped?

    # In a real application, this section would make use of the appropriate,
    # efficient database queries.
    ExampleModel.where(id: begin_id..end_id).each do |example_model|
      example_model.update(example_attribute: "example value")
    end
  end
end
