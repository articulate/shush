# It's a joke...
require "cryptor"
require "cryptor/symmetric_encryption/ciphers/xsalsa20poly1305"
require "redis"

class SecrestStore
  attr_reader :redis

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

  def save(encryption_key, value)
    redis.set(fingerprint(encryption_key), encrypt(encryption_key, value))
  end

  # Redis expire is in seconds, we're dealing in minutes
  def expire_in_minutes(encryption_key, minutes)
    redis.expire(fingerprint(encryption_key), (minutes.to_i * 60))
  end

  def fetch(key)
    content = redis.get(key)
    return false if content.nil?

    cryptor = Cryptor::SymmetricEncryption.new("secret.key:///xsalsa20poly1305;#{key}")
    cryptor.decrypt(content)
  end

  def destroy(key)
    redis.del(key)
  end

  # remember to convert to minutes coming back out to be consistent
  def expires_in(key)
    (redis.ttl(key).to_f / 60).round(2)
  end

  def auto_expire?(key)
     expires_in(key) >= 0
  end
end

