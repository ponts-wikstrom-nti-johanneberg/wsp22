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
    p params
    p "hej"
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    params.each do |key, value|
        card_id = key.split(" ")[1].to_i
        p card_id
        card_rating = value
        show_rating = db.execute("INSERT INTO user_ratinglist_relation (show_rating, cards_id) VALUES (?,?)", card_rating, card_id)
        p show_rating
    end
    redirect('/show_bronze')
end