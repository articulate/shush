require "omniauth"
require "omniauth-google-oauth2"
require_relative "eyes_web"

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

use OmniAuth::Builder do
  provider :google_oauth2, ENV["CLIENT_ID"], ENV["CLIENT_SECRET"]
end

run EyesWeb
