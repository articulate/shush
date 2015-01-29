# It's a joke...
require 'bcrypt'
require 'redis'

class SecrestStore
  attr_reader :redis

  def initialize(redis=Redis.new)
    @redis = redis
  end

  def encrypt(content)
    BCrypt::Password.create(content)
  end

  def save(key, value)
    redis.set(key, encrypt(value))
  end

  # Redis expire is in seconds, we're dealing in minutes
  def expire_in_minutes(key, minutes)
    redis.expire(key, (minutes.to_i * 60))
  end

  def fetch(key)
    redis.get(key)
  end

  def destroy(key)
    redis.del key
  end

  # remember to convert to minutes coming back out to be consistent
  def expires_in(key)
    (redis.ttl(key).to_f / 60).round(2)
  end

  def auto_expire?(key)
     expires_in(key) >= 0
  end
end
