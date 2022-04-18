require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader' if development?

enable :sessions
username = nil

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
    # db = SQLite3::Database.new("db/databas_be_like.db")
    # db.results_as_hash = true
    # rating_1star = db.execute("SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='1*'").first
    # p rating_1star
    # rating_2star = db.execute("SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='2*'").first
    # rating_3star = db.execute("SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='3*'").first
    # rating_4star = db.execute("SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='4*'").first
    # rating_5star = db.execute("SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='5*'").first
    # slim(:show_bronze, locals:{rating_1star:rating_1star, rating_2star:rating_2star, rating_3star:rating_3star, rating_4star:rating_4star, rating_5star:rating_5star})
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
      session[:username] = username
      redirect('/')
    else
      "The passwords were not meant to be."
    end
  end

get('/make_bronze') do
    if username == nil # Tidigare satt username som nil under enable :sessons, på get ('/login') får vi att username är något anant och går därför till den tänkta sidan.
        slim(:login)
    else
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM cards")
    p result
    slim(:make_yours_bronze, locals:{result:result})
    end
end

post('/make_bronze') do
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.results_as_hash = true
    p "username är #{username}"
    user_id = db.execute("SELECT id FROM user WHERE Name = ?", username).first
    user_id = user_id[0].to_i
    p "user_id är #{user_id}"
    ratinglist = db.execute("SELECT ratinglist FROM user_ratinglist_relation").last
    p "Ratinglist är #{ratinglist}"
    if ratinglist == nil
        ratinglist = 0
    else 
        ratinglist = ratinglist[ratinglist.length - 1].to_i
        p "Ratinglist är därmed #{ratinglist}"
    end
    ratinglist += 1
    p "Ny ratinglist är #{ratinglist}"
    params.each do |key, value|
        p key
        p value
        card_id = key.split(" ")[1].to_i
        p card_id
        card_rating = value
        show_rating = db.execute("INSERT INTO user_ratinglist_relation (show_rating, cards_id, ratinglist, user_id) VALUES (?,?,?,?)", card_rating, card_id, ratinglist, user_id)
        p show_rating
    end
    redirect('/show_bronze')
end