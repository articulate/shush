require_relative "secret_server"

use Rack::Parser, parsers: {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

run SecretServer
