# frozen_string_literal: true

class SpreadTracker
  def initialize(job_class, model_class)
    @job_class = job_class
    @model_class = model_class
  end

  def initial_id
    redis_value = redis.hget(initial_id_key, @model_class.name)

    value = redis_value || @model_class.maximum(:id)

    value.to_i
  end

  def initial_id=(value)
    if value.nil?
      redis.hdel(initial_id_key, @model_class.name)
    else
      redis.hset(initial_id_key, @model_class.name, value)
    end
  end

  private

  def redis
    SuperSpreader.redis
  end

  def initial_id_key
    "#{@job_class.name}:initial_id"
  end
end
