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
# card_ratings_array = []
card_rating = params[:card_rating]
    # while i < 29
    #     card_ratings_array << card_rating
    #     i += 1
    # end
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    show_rating = db.execute("INSERT INTO user_ratinglist_relation (show_rating) VALUES (?)", card_rating)
    p show_rating
    redirect('/show_bronze')
end