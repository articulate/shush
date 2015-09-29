require_relative "secret_server"
require 'rack/parser'

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

use Rack::Parser, parsers: {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

run SecretServer
