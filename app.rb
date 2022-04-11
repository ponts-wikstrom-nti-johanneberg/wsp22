require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader' if development?

enable :sessions

get ('/') do
    slim(:start)
end

get ('/register') do
    slim(:register)
end

get ('/login') do
    slim(:login)
end

get('/show_bronze') do
    slim(:show_bronze)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/databas_be_like.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user WHERE Name = ?",username).first
    pwdigest = result["Pwdigest"]
    id = result["id"]
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/')
    else
      "Wrong Password"
    end
  
  end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if password == password_confirm
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/databas_be_like.db')
      db.execute("INSERT INTO user (Name,Pwdigest) VALUES (?,?)",username,password_digest)
      redirect('/')
    else
      "The passwords were not meant to be."
    end
  end

get('/make_bronze') do
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM cards")
    p result
    slim(:make_yours_bronze, locals:{result:result})
end

post('/make_bronze') do
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