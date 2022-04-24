require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader' if development?
require_relative 'model/model.rb'

enable :sessions
include Model
username = nil
ratinglist = nil

# Display Start Menu
get ('/') do
    slim(:start)
end

# Display user registration.
#
get ('/users/register') do
    slim(:"/users/register")
end

# Display user login
#
get ('/users/login') do
    slim(:"/users/login")
end

# Display all cards in a rated list, with the cards that has the lowest rating furthers down, and the cards with the highest ratings at the top.
#
# @rating_1star [Hash], hash with cards that has 1 star 
# @rating_2star [Hash], hash with cards that has 2 star 
# @rating_3star [Hash], hash with cards that has 3 star 
# @rating_4star [Hash], hash with cards that has 4 star 
# @rating_5star [Hash], hash with cards that has 5 star 
# @username_list [hash], hash with a list of usernames that has made a list
#
# @see Model#show_bronze
get('/show_bronze') do
    rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list = {}, {}, {}, {}, {}, {}
    show_bronze(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
    slim(:show_bronze, locals:{rating_1star:rating_1star, rating_2star:rating_2star, rating_3star:rating_3star, rating_4star:rating_4star, rating_5star:rating_5star, ratinglist:ratinglist, username_list:username_list})
end

# Display all cards in a rated list, with the cards that has the lowest rating furthers down, and the cards with the highest ratings at the top. All of the lists shown can only the user who is logged in see.
#
# @rating_1star [Hash], hash with cards that has 1 star 
# @rating_2star [Hash], hash with cards that has 2 star 
# @rating_3star [Hash], hash with cards that has 3 star 
# @rating_4star [Hash], hash with cards that has 4 star 
# @rating_5star [Hash], hash with cards that has 5 star 
# @username_list [hash], hash with a list of usernames that has made a list
#
# @see Model#your_lists
get('/users/your_lists') do
    rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list = {}, {}, {}, {}, {}, {}
    your_lists(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
    slim(:"/users/your_lists", locals:{rating_1star:rating_1star, rating_2star:rating_2star, rating_3star:rating_3star, rating_4star:rating_4star, rating_5star:rating_5star, ratinglist:ratinglist, username_list:username_list})
end

# Attempts login and updates the session
#
# @param [String] username, The username
# @session [String] logging, Checks the time between first attempt of login and second attempt
# Time.now [String] logging, Second attempt of logging
# 
# redirects to '/error' if the time between first and second attemt is less than 10 seconds
before ('/users/login') do
    # username = params[:username]
    if session[:logging] != nil
        if Time.now - session[:logging] < 10
            redirect('/error/You_are_logging_in_too_fast._Please_slow_down.')
        end
    end
end

# Attempts login and updates the session
# @param [String], username, The username
# @param [String], password, The password
# @param [String], password_confirm, The repeated password

# if username == nil, redirect to '/error'
# else, redirect to '/'
# @see Model#new_user
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

#  Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
# @session [String] username, The username
# @session [String] logging, Checks the time between first attempt of login and second attempt
#
# if username == nil, redirects to '/error'
# else, redirects to '/'
#
# @see Model#bcrypt
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

# Display all cards for the user to rate
#
# if username == nil, redirects to '/login'
# else redirects to '/make_yours_bronze'
#
# @see Model#select_cards
get('/make_bronze') do
    if username == nil # Tidigare satt username som nil under enable :sessons, på get ('/login') får vi att username är något anant och går därför till den tänkta sidan.
        slim(:login)
    else
    result = select_cards()
    slim(:make_yours_bronze, locals:{result:result})
    end
end

# Creates new place for user to see cards to rate
#
# @db [Hash], connects database with ruby
# @param [Integer], card_id, The id for the specific card
# @param [Integer], card_rating, The value of the rating of one specific card
# @ratinglist [Integer], checks which list the cards will join
# @user_id [Integer], checks the id of the user who is logged on the site at that moment
#
# params.each, a loop that checks each specific card and its values
# redirects to '/show_bronze'
#
# @see Model#get_user
# @see Model@get_ratinglist
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

# Displays all cards in a specific rating list that the user wants to edit
#
# @param [Integer], ratinglist, Checks which rating list that gets edited
#
# redirects to '/edit'
#
# @see Model#edit_list
get('/:index/edit') do
    ratinglist = params[:index]
    result = edit_list(ratinglist)
    slim(:edit, locals:{result:result})
end

# Updates an already existing rating list
#
# @param [Integer], ratinglist, Checks which rating list that gets edited
# @db [Hash], connects database with ruby
# @param [Integer], card_id, The id for the specific card
# @param [Integer], card_rating, The value of the rating of one specific card
#
# params.each, a loop that checks each specific card and its values
# redirects to '/show_bronze'
#
# @see Model#get_user
# @see Model@get_ratinglist
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

# Deletes an existing rating list
#
# @param [Integer], ratinglist, Checks which rating list that gets deleted
#
# redirects to '/show_bronze'
#
# @see Model#delete_list
post ('/:index/delete') do
    ratinglist = params[:index]
    delete_list(ratinglist)
    redirect('/show_bronze')
end

# Displays an error message
#
get('/error/:error_message') do
    error_message = params[:error_message].split("_").join(" ")
    slim(:"/error/error", locals:{username:session[:username], error_message:error_message})
end