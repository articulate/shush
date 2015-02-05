require 'json'
require 'sinatra/base'
require "sinatra/content_for"
require 'cryptor'
require 'cryptor/symmetric_encryption/ciphers/xsalsa20poly1305'

require 'active_support/core_ext/numeric/time'
require 'action_view'
require 'action_view/helpers'

require 'byebug' if ENV['RACK_ENV'] == 'development'

if ENV["RACK_ENV"] == "production"
  require "rack/ssl-enforcer"
end

require_relative "secrest_store"

class EyesWeb < Sinatra::Base
  helpers Sinatra::ContentFor
  include ActionView::Helpers::DateHelper

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

  def timed?(expire)
    params[:expire] == "time"
  end

  def time_text(time)
    TIMES.key(time.to_i)
  end

  def generate_share_url(fingerprint)
    protocol = settings.force_ssl? ? "https" : "http"
    url = "#{protocol}://#{settings.host}/read/#{fingerprint}"
  end

  get "/" do
    haml :write
  end

  get "/about" do
    markdown :info, layout_engine: :haml
  end

  post "/save" do
    time = timed?(params[:expire]) ? params[:time].to_i : nil
    key = store.save(params[:secret], ttl: time)

    # Generate url with key
    protocol = settings.force_ssl? ? "https" : "http"

    haml :share, locals: { url: generate_share_url(key), time: time_text(time) }
  end

  get "/read/not_found" do
    haml :four_oh_four
  end

  get "/read/:fingerprint" do
    fingerprint = params[:fingerprint]

    redirect "/read/not_found" unless store.exists?(fingerprint)

    haml :read, locals: { key: fingerprint }
  end

  # JSON fetch
  get "/note/:fingerprint" do
    fingerprint = params[:fingerprint]
    note = store.fetch(fingerprint)

    if store.auto_expire?(fingerprint)
      ttl = store.expires_in(fingerprint)
    else
      store.destroy(fingerprint)
    end

    content_type :json
    { note: note.force_encoding(Encoding::UTF_8), ttl: ttl }.to_json
  end

  not_found do
    "\"You don't belong here.\" -Radiohead"
  end
end
