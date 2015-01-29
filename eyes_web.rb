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

    # Generate url with key
    url = "http://localhost:9393/read/akey"

    haml :share, locals: { url: url }
  end

  get "/read/:key" do
    note = store.fetch params[:key]

    # Decrypt...

    haml :note, locals: { note: note }
  end
end
