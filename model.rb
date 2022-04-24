require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

def show_bronze(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
    db = connect_to_db('db/databas_be_like.db')
    ratinglist = db.execute("SELECT ratinglist FROM user_ratinglist_relation").last["ratinglist"].to_i
    # p "ratinglist är #{ratinglist}"
    # p ratinglist
    (1..ratinglist).to_a.each do |index|
        # ratinglist = ratinglist.to_i
        rating_1star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='1' AND ratinglist=?)", index)
        # rating_1star[ratinglist] = rating_1star
        # return rating_0star.to_s
        # p "rating_1star är #{rating_1star}"
        rating_2star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='2' AND ratinglist=?)", index)
        # rating_1star[ratinglist] = rating_2star
        rating_3star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='3' AND ratinglist=?)", index)
        # rating_1star[ratinglist] = rating_3star
        rating_4star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='4' AND ratinglist=?)", index)
        # rating_1star[ratinglist] = rating_4star
        rating_5star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='5' AND ratinglist=?)", index)
        # rating_1star[ratinglist] = rating_5star
        username_list[index] = db.execute("SELECT Name FROM user WHERE id IN (SELECT user_id FROM user_ratinglist_relation WHERE ratinglist=?)", index).first
        p username_list
    end
end

def your_lists(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
    db = connect_to_db('db/databas_be_like.db')
    id = db.execute("SELECT id FROM user WHERE Name=?", session[:username]).last["id"].to_i
    p id
    ratinglist = db.execute("SELECT ratinglist FROM user_ratinglist_relation").last["ratinglist"].to_i
    # p "ratinglist är #{ratinglist}"
    # p ratinglist
    (1..ratinglist).to_a.each do |index|
        # ratinglist = ratinglist.to_i
        rating_1star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='1' AND ratinglist=? AND user_id=?)", index, id)
        # rating_1star[ratinglist] = rating_1star
        # return rating_0star.to_s
        # p "rating_1star är #{rating_1star}"
        rating_2star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='2' AND ratinglist=? AND user_id=?)", index, id)
        # rating_1star[ratinglist] = rating_2star
        rating_3star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='3' AND ratinglist=? AND user_id=?)", index, id)
        # rating_1star[ratinglist] = rating_3star
        rating_4star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='4' AND ratinglist=? AND user_id=?)", index, id)
        # rating_1star[ratinglist] = rating_4star
        rating_5star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='5' AND ratinglist=? AND user_id=?)", index, id)
        # rating_1star[ratinglist] = rating_5star
        username_list[index] = db.execute("SELECT Name FROM user WHERE id IN (SELECT user_id FROM user_ratinglist_relation WHERE ratinglist=?)", index).first
        p username_list
    end
end

def bcrypt(username, password)
    db = connect_to_db('db/databas_be_like.db')
    result = db.execute("SELECT * FROM user WHERE Name = ?",username).first
    pwdigest = result["Pwdigest"]
    id = result["id"]
    if BCrypt::Password.new(pwdigest) == password
        return username
    else
      return nil
    end
end

def new_user(username, password, password_confirm)
    if password == password_confirm
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/databas_be_like.db')
        return db.execute("INSERT INTO user (Name,Pwdigest) VALUES (?,?)",username,password_digest)
    else
        return nil
    end
end

def select_cards()
    db = connect_to_db('db/databas_be_like.db')
    return result = db.execute("SELECT * FROM cards")
end

def get_user_id(db, username)
    user_id = db.execute("SELECT id FROM user WHERE Name = ?", username).first
    user_id = user_id[0].to_i
    return user_id
end

def get_ratinglist(db)
    ratinglist = db.execute("SELECT ratinglist FROM user_ratinglist_relation").last
    p "Ratinglist är #{ratinglist}"
    if ratinglist == nil
        ratinglist = 0
    else 
        ratinglist = ratinglist[ratinglist.length - 1].to_i
        p "Ratinglist är därmed #{ratinglist}"
    end
    ratinglist += 1
    return ratinglist
end

# def make_bronze(key, value, ratinglist, user_id)
#     db = SQLite3::Database.new("db/databas_be_like.db")
#     db.results_as_hash = true
#     user_id = db.execute("SELECT id FROM user WHERE Name = ?", username).first
#     user_id = user_id[0].to_i
#     p "user_id är #{user_id}"
#     ratinglist = db.execute("SELECT ratinglist FROM user_ratinglist_relation").last
#     p "Ratinglist är #{ratinglist}"
#     if ratinglist == nil
#         ratinglist = 0
#     else 
#         ratinglist = ratinglist[ratinglist.length - 1].to_i
#         p "Ratinglist är därmed #{ratinglist}"
#     end
#     ratinglist += 1
#     session[:ratinglist] = ratinglist
#     p "Ny ratinglist är #{ratinglist}"
#     params.each do |key, value|
#         p key
#         p value
#         card_id = key.split(" ")[1].to_i
#         p card_id
#         card_rating = value
#         show_rating = db.execute("INSERT INTO user_ratinglist_relation (show_rating, cards_id, ratinglist, user_id) VALUES (?,?,?,?)", card_rating, card_id, ratinglist, user_id)
#         p show_rating
#     end
# end

def delete_list(ratinglist)
    db = SQLite3::Database.new("db/databas_be_like.db")
    db.execute("DELETE FROM user_ratinglist_relation WHERE ratinglist = ?",ratinglist)
end


# Vi kan gärna kolla på denna funktion sedan. Vet inte hur jag ska lägga in den här inne...
# def update_list(ratinglist, key, value)
#     db = connect_to_db('db/databas_be_like.db')
#     show_rating = db.execute("UPDATE user_ratinglist_relation SET show_rating=? WHERE ratinglist=? AND cards_id=?", card_rating, ratinglist, card_id)
#     return show_rating
# end

def edit_list(ratinglist)
    db = connect_to_db('db/databas_be_like.db')
    return result = db.execute("SELECT * FROM cards INNER JOIN user_ratinglist_relation ON cards.id = cards_id WHERE ratinglist=?", ratinglist)
end