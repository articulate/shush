require 'json'
require 'sinatra/base'
require "sinatra/contrib"
require 'rack-flash'
require 'cryptor'
require 'cryptor/symmetric_encryption/ciphers/xsalsa20poly1305'
require 'redcarpet'
require 'haml'

if ENV["RACK_ENV"] == "production"
  require "rack/ssl-enforcer"
  require "rack-json-logs"
else
  require 'byebug'
  require "letter_opener"
end

require_relative "objects/secret"
require_relative "services/ses_mailer"
require_relative "services/secret_store"
require_relative "services/mail_notifier"

class SecretServer < Sinatra::Base
  register Sinatra::Contrib

  FLASH_TYPES = %i[danger warning info success]

  set :session_secret, ENV["SESSION_SECRET"]
  use Rack::Session::Cookie, key:          "_rack_session",
                             path:         "/",
                             expire_after: 2592000, # In seconds
                             secret:       settings.session_secret

  use Rack::Flash, accessorize: FLASH_TYPES

  configure :development, :test do
    set :force_ssl, false
    set :redis_url, ENV.fetch('REDIS_URL', "redis://redis:6379")
    set :mailer, [LetterOpener::DeliveryMethod, location: File.expand_path('../tmp/letter_opener', __FILE__)]
  end

  configure :production do
    set :force_ssl, ENV.fetch('FORCE_SSL', true)
    set :redis_url, ENV["REDIS_URL"]
    set :mailer, [SESMailer, region: ENV.fetch('AWS_REGION', 'us-east-1')]

    use Rack::JsonLogs
  end

  set :redis, Redis.new(url: settings.redis_url)
  set :store, SecretStore.new(settings.redis)

  Mail.defaults do
    delivery_method *SecretServer.settings.mailer
  end

  def store
    settings.store
  end

  def slack_request?
    slack_token = ENV['SLACK_TOKEN']
    !slack_token.nil? && params[:token] == slack_token
  end

  def timed?
    params[:expire] == "time"
  end

  def notify_requested?
    !params[:notify].nil? && params[:notify] != ""
  end

  def generate_share_url(fingerprint)
    "#{request.scheme}://#{request.host}:#{request.port}/read/#{fingerprint}"
  end

  get "/" do
    haml :write
  end

  get "/health" do
    status = 200
    body = ""
  end

  get "/about" do
    markdown :info, layout_engine: :haml
  end

  post "/save", provides: [:html, :json] do
    secret = Secret.new params[:text],
      is_ttl: timed?,
      ttl: params[:time],
      notify: notify_requested?,
      email: params[:notify_email]

    key = store.save secret

    # Generate url with key
    protocol = settings.force_ssl? ? "https" : "http"
    url = generate_share_url(key)

    if slack_request?
      "<#{url}>"
    else
      respond_with :share, { url: url, time: secret.expire_in_words, key: key }
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
    secret = store.fetch(fingerprint)

    MailNotifier.notify_read(secret.email, fingerprint, is_ttl: secret.auto_expire?) if secret.notify?

    content_type :json
    {
      note: secret.message.force_encoding(Encoding::UTF_8),
      ttl: secret.expire_in_words
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
