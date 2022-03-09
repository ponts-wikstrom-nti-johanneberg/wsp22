require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader' if development?

enable :sessions

get ('/') do
    slim(:start)
end

get('/make_bronze') do
    slim(:make_yours_bronze)
end
