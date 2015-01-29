require 'sinatra/base'
require 'byebug' if ENV['RACK_ENV'] == 'development'
require 'bcrypt'

require_relative 'secrest_store'

class EyesWeb < Sinatra::Base
  def store
    include BCrypt

    @store ||= SecrestStore.new
  end

  get '/' do
    haml :input
  end

  post '/save' do
    # Generate key
    # Then encrypt
    store.save "akey", params[:secret]
    redirect '/share'
  end

  get '/share' do
    "A link should have been here..."
  end
end
