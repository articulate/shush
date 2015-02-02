# It's a joke...
require "cryptor"
require "cryptor/symmetric_encryption/ciphers/xsalsa20poly1305"
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

  def encrypt(encryption_key, content)
    cryptor = Cryptor::SymmetricEncryption.new(encryption_key)
    cryptor.encrypt(content)
  end

  def fingerprint(encryption_key)
    fingerprint = encryption_key.to_secret_uri
    fingerprint.split(";")[1] # get the unique bit
  end

  def save(encryption_key, value, ttl:)
    ttl ||= MAX_TTL
    redis.setex(fingerprint(encryption_key), to_seconds(ttl), encrypt(encryption_key, value))
  end

  def fetch(key)
    content = redis.get(key)
    return false if content.nil?

    cryptor = Cryptor::SymmetricEncryption.new("secret.key:///xsalsa20poly1305;#{key}")
    cryptor.decrypt(content)
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

