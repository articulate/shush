# It's a joke...
require_relative 'crypt'
require "redis"

TIMES = {
  "10 minutes" => 10,
  "1 hour"     => 60,
  "1 day"      => 1440,
  "1 week"     => 10080,
}

class SecrestStore
  attr_reader :redis

  MAX_TTL = TIMES.values.max

  def initialize(redis=Redis.new)
    @redis = redis
  end

  def encrypt(content)
    Crypt.new.encrypt(content)
  end

  def save(secret, ttl:)
    # ttl ||= MAX_TTL
    crypt = Crypt.new
    key = crypt.fingerprint
    value = crypt.encrypt(secret)

    if ttl
      redis.setex(key, to_seconds(ttl), value)
    else
      redis.set(key, value)
    end

    key
  end

  def fetch(key)
    content = redis.get(key)
    return false if content.nil?

    crypt = Crypt.from_fingerprint(key)
    crypt.decrypt(content)
  end

  def exists?(key)
    redis.exists key
  end

  def destroy(key)
    redis.del(key)
  end

  # remember to convert to minutes coming back out to be consistent
  def expires_in(key)
    to_minutes redis.ttl(key)
  end

  def auto_expire?(key)
    expires_in(key) >= 0
  end

  private

  def to_seconds(time)
    time * 60
  end

  def to_minutes(time)
    (time.to_f / 60).round(2)
  end
end
