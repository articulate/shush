require 'json'
require 'sinatra/base'
require "sinatra/content_for"
require 'cryptor'
require 'cryptor/symmetric_encryption/ciphers/xsalsa20poly1305'

require 'byebug' if ENV['RACK_ENV'] == 'development'

if ENV["RACK_ENV"] == "production"
  require "rack/ssl-enforcer"
end

require_relative "secrest_store"

TIMES = {
  "10 minutes" => 10,
  "1 hour"     => 60,
  "1 day"      => 1440,
  "1 week"     => 10080,
}

class EyesWeb < Sinatra::Base
  helpers Sinatra::ContentFor

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

  set :redis, Redis.new(url: settings.redis_url)
  set :store, SecrestStore.new(settings.redis)

  def store
    settings.store
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

    is_timed = params[:expire] == "time"

    store.expire_in_minutes(key, params[:time]) if is_timed
    time = is_timed ? TIMES.key(params[:time].to_i) : nil

    # Generate url with key
    protocol = settings.force_ssl? ? "https" : "http"
    url = "#{protocol}://#{settings.host}/read/#{store.fingerprint(key)}"

    content_type :json
    { url: url, time: time }.to_json
  end

  get "/read/not_found" do
    haml :four_oh_four
  end

  get "/read/:key" do
    key = params[:key]

    redirect "/read/not_found" unless store.exists?(key)

    haml :note, locals: { key: key }
  end

  # JSON fetch
  get "/note/:key" do
    key = params[:key]
    note = store.fetch(key)

    if store.auto_expire?(key)
      ttl = store.expires_in(key)
    else
      store.destroy(key)
    end

    content_type :json
    { note: note, ttl: ttl }.to_json
  end

  get "/keybase" do
    haml :keybase_auth
  end

  post "/keybase" do
    me = Keybase::Core::User.login(params[:username], params[:password])
    redirect "/"
  end

  not_found do
    "\"You don't belong here.\" -Radiohead"
  end
end
