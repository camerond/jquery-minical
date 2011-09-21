require 'sinatra'
require 'haml'

require "sinatra/reloader" if development?

before do
  response.headers['Cache-Control'] = 'public, max-age=604800' if production?
end

get '/stylesheets/*.css' do |f|
  sass ('/stylesheets/' + f).to_sym
end

get '/' do
  @readme = ('../README').to_sym
  haml :index
end
