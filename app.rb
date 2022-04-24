require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader' if development?
require_relative '/model/model.rb'

# Vad jag ska göra:
# Lägga till Edit button, eventuellt att jag gör det på varje rad/varje kort. Tar isåfall all information från enskilda raden/kortet och går in på en ny sida som isåfall ändrar value på det kortet.
# Hjälpfunktioner
# Delete button
# User settings, ska kunna editta ens egna, kunna eventuellt se ens egna
# Admin settings? Kunna edita/ta bort andras?

enable :sessions
include Model
username = nil
ratinglist = nil

# Display Start Menu
get ('/') do
    slim(:start)
end

# 
get ('/users/register') do
    slim(:"/users/register")
end

get ('/users/login') do
    slim(:"/users/login")
end

get('/show_bronze') do
    rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list = {}, {}, {}, {}, {}, {}
    show_bronze(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
    slim(:show_bronze, locals:{rating_1star:rating_1star, rating_2star:rating_2star, rating_3star:rating_3star, rating_4star:rating_4star, rating_5star:rating_5star, ratinglist:ratinglist, username_list:username_list})
end

get('/users/your_lists') do
    rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list = {}, {}, {}, {}, {}, {}
    your_lists(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
    slim(:"/users/your_lists", locals:{rating_1star:rating_1star, rating_2star:rating_2star, rating_3star:rating_3star, rating_4star:rating_4star, rating_5star:rating_5star, ratinglist:ratinglist, username_list:username_list})
end

# Funktionen kollar ifall personen som loggar in använder sig av rätt lösenord med motsvarande användarnamn.
before ('/users/login') do
    username = params[:username]
    if session[:logging] != nil
        if Time.now - session[:logging] < 10
            redirect('/error/You_are_logging_in_too_fast._Please_slow_down.')
        end
    end
end

post('/users/login') do
    username = params[:username]
    password = params[:password]
    session[:logging] = Time.now
    username = bcrypt(username, password)
    if username == nil
        redirect('/error/Wrong_password_or_username.')
    end
    session[:username] = username
    redirect('/')
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    username = new_user(username, password, password_confirm)
    p username
    if username == nil
        redirect('/error/The_passwords_did_not_match_each_other._Did_you_write_everything_correctly?')
    else
        redirect('/')
    end
end

get('/make_bronze') do
    if username == nil # Tidigare satt username som nil under enable :sessons, på get ('/login') får vi att username är något anant och går därför till den tänkta sidan.
        slim(:login)
    else
    result = select_cards()
    slim(:make_yours_bronze, locals:{result:result})
    end
end

post('/make_bronze') do
    db = connect_to_db('db/databas_be_like.db')
    username = session[:username]
    user_id = get_user_id(db, username)
    p "user_id är #{user_id}"
    ratinglist = get_ratinglist(db)
    p "Ny ratinglist är #{ratinglist}"
    params.each do |key, value|
        p key
        p value
        card_id = key.split(" ")[1].to_i
        p card_id
        card_rating = value
        # Kan inte lägga denna del i model.rb, kollar gärna över detta senare, men i nuläget vet jag inte varför.
        show_rating = db.execute("INSERT INTO user_ratinglist_relation (show_rating, cards_id, ratinglist, user_id) VALUES (?,?,?,?)", card_rating, card_id, ratinglist, user_id)
        p show_rating
    end
    redirect('/show_bronze')
end

post ('/:index/update') do
    ratinglist = params[:index]
    db = connect_to_db('db/databas_be_like.db')
    params.each do |key, value|
        p "key är #{key}"
        p "value är #{value}" 
        card_id = key.split(" ")[1].to_i
        p "card_id är #{card_id}"
        card_rating = value
        # Kan inte lägga denna del i model.rb, kollar gärna över detta senare, men i nuläget vet jag inte varför.
        show_rating = db.execute("UPDATE user_ratinglist_relation SET show_rating=? WHERE ratinglist=? AND cards_id=?", card_rating, ratinglist, card_id)
        p show_rating
    end
    redirect('/show_bronze')
end

post ('/:index/delete') do
    ratinglist = params[:index]
    delete_list(ratinglist)
    redirect('/show_bronze')
end

get('/:index/edit') do
    ratinglist = params[:index]
    result = edit_list(ratinglist)
    slim(:edit, locals:{result:result})
end

get('/error/:error_message') do
    error_message = params[:error_message].split("_").join(" ")
    slim(:"/error/error", locals:{username:session[:username], error_message:error_message})
end