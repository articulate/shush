require_relative "eyes_web"
require 'rack/parser'

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

use Rack::Parser, parsers: {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

run EyesWeb
