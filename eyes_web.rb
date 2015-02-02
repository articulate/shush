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

  def timed?(expire)
    params[:expire] == "time"
  end

  def time_text(time)
    TIMES.key(time.to_i)
  end

  get "/" do
    haml :input
  end

  get "/about" do
    markdown :info, layout_engine: :haml
  end

  post "/save" do
    key = encryption_key

    time = timed?(params[:expire]) ? params[:time].to_i : nil
    store.save(key, params[:secret], ttl: time)

    # Generate url with key
    protocol = settings.force_ssl? ? "https" : "http"
    url = "#{protocol}://#{settings.host}/read/#{store.fingerprint(key)}"

    haml :share, locals: { url: url, time: time_text(time) }
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

  not_found do
    "\"You don't belong here.\" -Radiohead"
  end
end
