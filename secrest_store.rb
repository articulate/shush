# It's a joke...
require 'redis'

class SecrestStore
  attr_reader :redis

  def initialize(redis=Redis.new)
    @redis = redis
  end

  def save(key, value)
    redis.set(key, value)
  end

  def save_for_time(key, value, for_time:)
    redis.save(key, value)
    redis.expire(key, for_time)
  end

  def fetch(key)
    redis.get(key)
  end
end
