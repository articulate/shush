require 'sinatra/base'
require 'byebug' if ENV['RACK_ENV'] == 'development'
require 'bcrypt'

require_relative 'secrest_store'

class EyesWeb < Sinatra::Base
  include BCrypt
  def store
    @store ||= SecrestStore.new
  end

  def key
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...50).map { o[rand(o.length)] }.join
  end

  get '/' do
    haml :input
  end

  post '/save' do
    store.save key, params[:secret]

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
