require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

module Model
    # Connects database with ruby
    # @return [Hash] containing database
    def connect_to_db(path)
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end
    # Makes a rating list with cards that has 1 star, 2 star, 3 star, 4 star and 5 star, aswell as with a username
    # 
    # @db [Hash], connects database with ruby
    # @ratinglist [Integer], selects the last made ratinglist in the table user_ratinglist_relation
    # @rating_1star [Hash], hash with cards that has 1 star 
    # @rating_2star [Hash], hash with cards that has 2 star 
    # @rating_3star [Hash], hash with cards that has 3 star 
    # @rating_4star [Hash], hash with cards that has 4 star 
    # @rating_5star [Hash], hash with cards that has 5 star 
    # @username_list [hash], hash with a list of usernames that has made a list
    # @return [Hash], containing the data of all cards into a rating list
    def show_bronze(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
        db = connect_to_db('db/databas_be_like.db')
        ratinglist = db.execute("SELECT ratinglist FROM user_ratinglist_relation").last["ratinglist"].to_i
        (1..ratinglist).to_a.each do |index|
            rating_1star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='1' AND ratinglist=?)", index)
            rating_2star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='2' AND ratinglist=?)", index)
            rating_3star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='3' AND ratinglist=?)", index)
            rating_4star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='4' AND ratinglist=?)", index)
            rating_5star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='5' AND ratinglist=?)", index)
            username_list[index] = db.execute("SELECT Name FROM user WHERE id IN (SELECT user_id FROM user_ratinglist_relation WHERE ratinglist=?)", index).first
        end
    end

    # Makes all of the rating list that the user who is logged in has with cards that has 1 star, 2 star, 3 star, 4 star and 5 star, aswell as with a username
    # 
    # @db [Hash], connects database with ruby
    # @id [Integer], selects the id of the user who is logged on at the moment
    # @ratinglist [Integer], selects the last made ratinglist in the table user_ratinglist_relation
    # @rating_1star [Hash], hash with cards that has 1 star 
    # @rating_2star [Hash], hash with cards that has 2 star 
    # @rating_3star [Hash], hash with cards that has 3 star 
    # @rating_4star [Hash], hash with cards that has 4 star 
    # @rating_5star [Hash], hash with cards that has 5 star 
    # @username_list [hash], hash with a list of rating lists that the user has
    # @return [Hash], containing the new data of all cards into a rating list
    def your_lists(rating_1star, rating_2star, rating_3star, rating_4star, rating_5star, username_list)
        db = connect_to_db('db/databas_be_like.db')
        id = db.execute("SELECT id FROM user WHERE Name=?", session[:username]).last["id"].to_i
        ratinglist = db.execute("SELECT ratinglist FROM user_ratinglist_relation").last["ratinglist"].to_i
        (1..ratinglist).to_a.each do |index|
            rating_1star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='1' AND ratinglist=? AND user_id=?)", index, id)
            rating_2star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='2' AND ratinglist=? AND user_id=?)", index, id)
            rating_3star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='3' AND ratinglist=? AND user_id=?)", index, id)
            rating_4star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='4' AND ratinglist=? AND user_id=?)", index, id)
            rating_5star[index] = db.execute("SELECT * FROM cards WHERE id IN (SELECT cards_id FROM user_ratinglist_relation WHERE show_rating='5' AND ratinglist=? AND user_id=?)", index, id)
            username_list[index] = db.execute("SELECT Name FROM user WHERE id IN (SELECT user_id FROM user_ratinglist_relation WHERE ratinglist=?)", index).first
        end
    end

    # Checks if the firstly written password is the same as the second written password
    #
    # @db [Hash], Connects database with ruby
    #
    # @return [Hash], if passwords matches, The username and the digested password of the new user
    # @return [Nil], if passwords does not match
    def new_user(username, password, password_confirm)
        if password == password_confirm
            password_digest = BCrypt::Password.create(password)
            db = SQLite3::Database.new('db/databas_be_like.db')
            return db.execute("INSERT INTO user (Name,Pwdigest) VALUES (?,?)",username,password_digest)
        else
            return nil
        end
    end

    # Checks if the digested password is the same as the password the user uses
    #
    # @db [Hash], connects database with ruby
    # @result [Hash], selects all of the tables inside of the user table where Name is username
    # @pwdigest [String], picks up the table "Pwdigest" from user
    # @id [Integer], picks up the id from the table user
    # @option params [String], username, The username
    # @option params [String], password, The password
    #
    # @return [String], if password matches pwdigest
    # @return [Nil], if password does not match pwdigest 
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

    # Selects all of the fields in the table cards
    #
    # @db [Hash], connects database with ruby
    #
    # @return [Hash], All of the fields from the table cards
    def select_cards()
        db = connect_to_db('db/databas_be_like.db')
        return result = db.execute("SELECT * FROM cards")
    end

    # Selects the id from user where the username is the logged in user
    #
    # @session [String], username, The username of the logged in user
    # @user_id [Integer], Selected id from the table user
    #
    # @return [Integer], id from the table user
    def get_user_id(db, username)
        user_id = db.execute("SELECT id FROM user WHERE Name = ?", username).first
        user_id = user_id[0].to_i
        return user_id
    end

    #Selects the last ratinglist from user_ratinglist_relation
    #
    # @ratinglist [Integer], Selected ratinglist from the table user_ratinglist_relation
    #
    # @return [Integer], ratinglist, either it returns the first rating list, or any other after with an integer with a value that incrementate 1
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

    # Vi kan gärna kolla på denna funktion sedan. Vet inte hur jag ska lägga in den här inne...
    # def make_bronze(key, value, ratinglist, user_id)
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

    # Deletes the rating list that the user owns
    #
    # db [Hash], connects database with ruby
    #
    # @return, deleted rating list
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

    # Updates one rating list that the user owns
    #
    # db [Hash], connects database with ruby
    #
    # return [Hash], All of the fields in the table cards that has the same id as the cards_id in the table user_ratinglist_relation where the ratinglist equals the ratinglist that the user clicked on
    def edit_list(ratinglist)
        db = connect_to_db('db/databas_be_like.db')
        return result = db.execute("SELECT * FROM cards INNER JOIN user_ratinglist_relation ON cards.id = cards_id WHERE ratinglist=?", ratinglist)
    end

end