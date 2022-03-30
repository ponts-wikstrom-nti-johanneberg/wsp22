require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader' if development?

enable :sessions

get ('/') do
    slim(:start)
end

get('/show_bronze') do
    slim(:show_bronze)
end

get('/make_bronze') do
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM cards")
    p result
    slim(:make_yours_bronze, locals:{result:result})
end

post('/make_bronze') do
    p "hej"
i = 1
card_ratings_array = []
    while i < 29
        card_ratings_array << params[:card_rating[i]]
        i += 1
    end
    p card_ratings_array
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    db.execute("SELECT * FROM cards")
    redirect('/show_bronze')
end