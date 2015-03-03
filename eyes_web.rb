require 'json'
require 'sinatra/base'
require "sinatra/contrib"
require 'rack-flash'
require 'cryptor'
require 'cryptor/symmetric_encryption/ciphers/xsalsa20poly1305'

require 'active_support/core_ext/numeric/time'
require 'action_view'
require 'action_view/helpers'

if ENV["RACK_ENV"] == "production"
  require "rack/ssl-enforcer"
  require 'postmark'
else
  require 'byebug'
  require "letter_opener"
end

require_relative "secrest_store"
require_relative "mail_notifier"

class EyesWeb < Sinatra::Base
  register Sinatra::Contrib

  include ActionView::Helpers::DateHelper

  FLASH_TYPES = %i[danger warning info success]

  set :session_secret, ENV["SESSION_SECRET"]
  use Rack::Session::Cookie, key:          "_rack_session",
                             path:         "/",
                             expire_after: 2592000, # In seconds
                             secret:       settings.session_secret

  use Rack::Flash, accessorize: FLASH_TYPES

  configure :development, :test do
    set :host, "articulatedev.com:9393"
    set :force_ssl, false
    set :redis_url, "redis://articulatedev.com:6379"
    set :mailer, [LetterOpener::DeliveryMethod, location: File.expand_path('../tmp/letter_opener', __FILE__)]
  end

  configure :production do
    set :host, "shush.articulate.com"
    set :force_ssl, true
    set :redis_url, ENV["REDISTOGO_URL"]
    set :mailer, [Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']]
  end

  set :redis, Redis.new(url: settings.redis_url)
  set :store, SecrestStore.new(settings.redis)

  Mail.defaults do
    delivery_method *EyesWeb.settings.mailer
  end

  def store
    settings.store
  end

  def slack_request?
    params[:token] == ENV['SLACK_TOKEN']
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

  post "/save", provides: [:html, :json] do
    time = timed?(params[:expire]) ? params[:time].to_i : nil
    key = store.save params[:text],
      ttl: time,
      notify: !params[:notify].nil? && params[:notify] != "",   # empty for CLI
      email: params[:notify_email]

    # Generate url with key
    protocol = settings.force_ssl? ? "https" : "http"
    url = generate_share_url(key)

    if slack_request?
      "<#{url}>"
    else
      respond_with :share, { url: url, time: time_text(time), key: key }
    end
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
    data = store.fetch(fingerprint)
    ttl = data[:is_ttl] ? store.expires_in(fingerprint) : nil

    MailNotifier.notify_read(data[:email], fingerprint, is_ttl: data[:is_ttl]) if data[:request_notify]

    content_type :json
    {
      note: data[:secret].force_encoding(Encoding::UTF_8),
      ttl: time_text(ttl)
    }.to_json
  end

  get '/destroy/:key' do
    store.destroy params[:key]

    flash[:success] = "Secret has been destroyed!"
    redirect "/"
  end

  not_found do
    "\"You don't belong here.\" -Radiohead"
  end
end
