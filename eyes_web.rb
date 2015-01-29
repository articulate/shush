require 'sinatra/base'

class EyesWeb < Sinatra::Base
  get '/' do
    'Hello World!'
  end
end
