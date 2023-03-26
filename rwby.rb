require 'net/http'
require 'uri'
require 'openssl'
require 'yaml'
require 'xpath'
require 'curb'
require 'nokogiri'
require 'date'
require 'json'
require './sender.rb'
require './helper.rb'
require './user.rb'

user = User.new

# First unauthorized request to pass.rw.by, just to get session token 
send_request_for_session_token(user)

# Login post request
send_first_post_request(user)

# Login get http request, I don’t know why I’m sending it, but for clarity I’ll do it
send_third_get_request(user)

# Login get https request, return to us logged_time header
send_third_get_request(user)

# Returns long params string about your route and free_seats(an example can be seen at the end of the method)
params_for_request = get_route_params(user)
p 'smth get wrong, maybe no free seats, or maybe site doesnt work rn' unless params_for_request

# Returns to us guid after we send the long string from the previous method
send_request_for_guid(params_for_request, user)

# Returns the train info and emptyPlaces
free_places_hash = send_ajax_req_for_free_places_hash(user)

# Returns the location of seats in the train by pixels
second_ajax_resp = send_ajax_req_for_train_pixels(free_places_hash, user)

# Send all info about train, seats and your seat
send_request_with_seat_info(free_places_hash, second_ajax_resp, user)

# Send last request with user info(first-middle-last names, passport data, etc)
send_passanger_info(user)

# Should check if the ticket has appeared in the backet or not(dont work right now)
send_orders_request(user)
