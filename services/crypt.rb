require "cryptor"
require "cryptor/symmetric_encryption/ciphers/xsalsa20poly1305"

class Crypt
  def self.random_key
    Cryptor::SymmetricEncryption.random_key(:xsalsa20poly1305)
  end

  # Share bit
  #   1 = Open
  #   0 = Articulate Only

  def initialize(key=self.class.random_key)
    @key = key
    @client = Cryptor::SymmetricEncryption.new(key)
  end

  def self.from_fingerprint(finger)
    new "secret.key:///xsalsa20poly1305;#{finger}"
  end

  def fingerprint
    finger = @key.to_secret_uri
    finger = finger.split(";")[1] # get the unique bit
  end

  def encrypt(content)
    @client.encrypt(content)
  end

  def decrypt(content)
    @client.decrypt content
  end
end
