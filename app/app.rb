require "sinatra/base"

module Portfolio
  class App < Sinatra::Base
    get '/' do
      'hello'
    end
  end
end
