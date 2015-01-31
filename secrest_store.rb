# It's a joke...
require_relative 'crypt'
require "redis"

TIMES = {
  "10 minutes" => 10,
  "1 hour"     => 60,
  "1 day"      => 1440,
  "1 week"     => 10080,
}

DATA_KEYS = %i[
  secret
  is_ttl
  org_only
]

class SecrestStore
  attr_reader :redis
  attr_accessor :access_token, :domain

  MAX_TTL = TIMES.values.max

  def initialize(redis=Redis.new)
    @redis = redis
  end

  def encrypt(content)
    Crypt.new.encrypt(content)
  end

  def save(secret, ttl:, org_only:)
    crypt = Crypt.new
    key = crypt.fingerprint
    value = crypt.encrypt(secret)

    data = format_data(value,
      is_ttl: !ttl.nil?,
      org_only: org_only)

    redis.mapped_hmset key, data
    set_expire key, (ttl || MAX_TTL)

    key
  end

  def fetch(key)
    content = redis.mapped_hmget(key, *DATA_KEYS)
    return false if content.nil?

    is_ttl = bool content[:is_ttl]
    destroy(key) unless is_ttl

    crypt = Crypt.from_fingerprint(key)
    unsecret = crypt.decrypt(content[:secret])

    format_data unsecret,
      is_ttl: is_ttl,
      org_only: bool(content[:org_only])
  end

  def exists?(key)
    redis.exists(key)
  end

  def destroy(key)
    redis.del(key)
  end

  # remember to convert to minutes coming back out to be consistent
  def expires_in(key)
    to_minutes redis.ttl(key)
  end

  def auto_expire?(key)
    bool redis.hget(key, :is_ttl)
  end

  def org_only?(key)
    bool redis.hget(key, :org_only)
  end

  private

  # forces text keys from redis into booleans
  def bool(val)
    val == "true"
  end

  def format_data(secret, is_ttl: false, org_only: false)
    {
      secret: secret,
      is_ttl: is_ttl,
      org_only: org_only
    }
  end

  def set_expire(key, time)
    redis.expire key, to_seconds(time)
  end

  def to_seconds(time)
    time * 60
  end

  def to_minutes(time)
    (time.to_f / 60).round(2)
  end
end
