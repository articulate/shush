require 'sinatra/base'

class EyesWeb < Sinatra::Base
  get '/' do
    haml :input
  end
end
