require "json"
require "sinatra/base"
require "sinatra/content_for"
require "cryptor"
require "cryptor/symmetric_encryption/ciphers/xsalsa20poly1305"
require "rack/ssl-enforcer" if ENV["RACK_ENV"] == "production"

require 'active_support/core_ext/numeric/time'
require 'action_view'
require 'action_view/helpers'

require "rack/ssl-enforcer" if ENV["RACK_ENV"] == "production"
require "byebug" if ENV["RACK_ENV"] == "development"

require_relative "secrest_store"

class EyesWeb < Sinatra::Base
  helpers Sinatra::ContentFor
  include ActionView::Helpers::DateHelper

  set :session_secret, ENV["SESSION_SECRET"]

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

  use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"
  use Rack::Session::Cookie, key:          "_rack_session",
                             path:         "/",
                             expire_after: 2592000, # In seconds
                             secret:       settings.session_secret

  use OmniAuth::Builder do
    provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], { prompt: "select_account" }
  end

  def store
    settings.store
  end

  def timed?(expire)
    params[:expire] == "time"
  end

  def time_text(time)
    (time && time > 0) ? "in #{time_ago_in_words(time.minutes.from_now)}" : "immediately"
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
    key = store.save(params[:secret], ttl: time, org_only: params[:org_only])

    haml :share, locals: { url: generate_share_url(key), time: time_text(time), key: key }
  end

  get "/read/not_found" do
    haml :four_oh_four
  end

  get "/read/:fingerprint" do
    fingerprint = params[:fingerprint]

    redirect "/auth/google_oauth2" if fingerprint[-1] == "0"

    redirect "/read/not_found" unless store.exists?(fingerprint)

    haml :read, locals: { key: fingerprint }
  end

  # JSON fetch
  get "/note/:fingerprint" do
    fingerprint = params[:fingerprint]
    data = store.fetch(fingerprint)

    content_type :json
    {
      note: data[:secret].force_encoding(Encoding::UTF_8),
      ttl: time_text(store.expires_in(fingerprint))
    }.to_json
  end

  get "/auth/:provider" do
    puts request.env['omniauth.auth']
  end

  get "/auth/:provider/callback" do
    puts request.env['omniauth.auth']
  end
end

