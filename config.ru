require_relative "eyes_web"

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

run EyesWeb
