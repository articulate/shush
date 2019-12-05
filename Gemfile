source "https://rubygems.org"

gem "actionview"
gem "cryptor"
gem "haml"
gem "redcarpet"
gem "rack-parser"
gem "rake"
gem "rbnacl-libsodium"
gem "redis"
gem "sinatra", "~> 2.0.3"
gem 'sinatra-contrib'
gem 'rack-flash3', git: 'https://github.com/treeder/rack-flash'
gem 'http'
gem 'tilt', "~>2.0"
gem 'sqreen', '>= 1.16'

group :development do
  gem "byebug"
  gem "shotgun"
  gem "letter_opener"
end

group :production do
  gem 'aws-sdk', '~> 2'
  gem 'puma', '~> 3.12.2'
  gem "rack-json-logs"
end
