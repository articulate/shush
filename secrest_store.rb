# It's a joke...
require_relative 'crypt'
require "redis"

class SecrestStore
  attr_reader :redis

  def initialize(redis=Redis.new)
    @redis = redis
  end

  def save(secret)
    crypt = Crypt.new
    key = crypt.fingerprint
    encrypted = crypt.encrypt(secret.message)
    secret.message = encrypted

    redis.mapped_hmset key, secret.to_h
    set_expire key, secret.expire_in_seconds

    key
  end

  def fetch(key)
    content = redis.mapped_hmget(key, *Secrest::DATA_KEYS)
    return false if content.nil?

    secret = Secrest.from_redis(content, expires_in(key))

    crypt = Crypt.from_fingerprint(key)
    unsecret = crypt.decrypt(secret.message)
    secret.message = unsecret

    destroy(key) unless secret.auto_expire?

    secret
  end

  def exists?(key)
    redis.exists key
  end

  def destroy(key)
    redis.del(key)
  end

  # remember to convert to minutes coming back out to be consistent
  def expires_in(key)
    redis.ttl(key)
  end

  private

  def set_expire(key, time)
    redis.expire key, time
  end
end
