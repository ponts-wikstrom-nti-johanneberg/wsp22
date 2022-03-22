require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader' if development?

enable :sessions

get ('/') do
    slim(:start)
end

get('/show_bronze') do
end

get('/make_bronze') do
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM cards")
    p result
    slim(:make_yours_bronze, locals:{result:result})
end

post('/make_bronze') do
    
    redirect('/show_bronze')
end