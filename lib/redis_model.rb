# frozen_string_literal: true

require "active_model"

class RedisModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  def initialize(values = default_values)
    super
  end

  def default_values
    redis.hgetall(redis_key)
  end

  def persisted?
    redis.get(redis_key).present?
  end

  def delete
    redis.del(redis_key)
  end

  def save
    redis.multi do
      delete

      serializable_hash.each do |key, value|
        redis.hset(redis_key, key, value)
      end
    end
  end

  # Primarily for factory_bot:lint
  alias save! save

  private

  def redis_key
    self.class.name
  end

  def redis
    SuperSpreader.redis
  end
end
