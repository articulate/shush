require "sinatra/base"
require "cryptor"
require "cryptor/symmetric_encryption/ciphers/xsalsa20poly1305"
require "byebug" if ENV["RACK_ENV"] == "development"

if ENV["RACK_ENV"] == "production"
  require "rack/ssl-enforcer"
end

require_relative "secrest_store"

TIMES = {
  "1 week" => 10080,
  "1 day" => 1440,
  "1 hour" => 60,
  "10 minutes" => 10,
  "1 minute" => 1,
}

class EyesWeb < Sinatra::Base

  configure :development, :test do
    set :host, "articulatedev.com:9393"
    set :force_ssl, false
    set :redis_url, "redis://articulatedev.com:6379"
  end

  configure :production do
    set :host, "shush.articulate.com"
    set :force_ssl, true
    set :redis_url, ENV["REDISTOGO_URL"]
  end

  def store
    @store ||= SecrestStore.new(Redis.new(url: settings.redis_url))
  end

  def encryption_key
    Cryptor::SymmetricEncryption.random_key(:xsalsa20poly1305)
  end

  get "/" do
    haml :input
  end

  post "/save" do
    key = encryption_key
    store.save(key, params[:secret])
    store.expire_in_minutes(key, params[:time]) if params[:expire] == "time"

    # Generate url with key
    protocol = settings.force_ssl? ? "https" : "http"
    url = "#{protocol}://#{settings.host}/read/#{store.fingerprint(key)}"
    haml :share, locals: { url: url, time: TIMES.key(params[:time].to_i) }
  end

  get "/read/:key" do
    key = params[:key]
    note = store.fetch(key)

    return 404 unless note

    if store.auto_expire?(key)
      ttl = store.expires_in(key)
    else
      store.destroy(key)
    end

    haml :note, locals: { note: note, ttl: ttl }
  end

  not_found do
    "That note does not exist!"
  end
end

