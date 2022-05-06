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

$lang = 'a99e6f9df71a6809253b6a85825dec8e3130af73%7Een'
$logged_fname = nil
$logged_lname = nil
$logged_email = nil
$guid = nil
$logged_token = nil
$session = nil
$logged_time = nil

# First unauthorized request to pass.rw.by, just to get session token 
send_req_for_session_token
# Login post request
cookie = send_first_post_req
# Login get http request, I don’t know why I’m sending it, but for clarity I’ll do it
send_second_get_req(cookie)
# Login get https request, return to us logged_time header
send_third_get_req(cookie)
# returns long params string about your route and free_seats(an example can be seen at the end of the method)
params_for_request = get_route_params
# returns to us guid after we send the long string from the previous method
send_request_for_guid(params_for_request)
# returns the train info and emptyPlaces
free_places_hash = send_ajax_req_for_free_places_hash
# returns the location of seats in the train by pixels
second_ajax_resp = send_ajax_req_for_train_pixels(free_places_hash)
# Send all info about train, seats and your seat
send_request_with_seat_info(free_places_hash, second_ajax_resp)
# Send last request with user info(first-middle-last names, passport data, etc)
send_passanger_info
# Should check if the ticket has appeared in the backet or not(dont work right now)
send_orders_request

p 'guid: ' + $guid
p 'logged_fname: ' + $logged_fname
p 'logged_lname: ' + $logged_lname
p 'logged_email: ' + $logged_email
p 'logged_token: ' + $logged_token
p 'session: ' + $session
p 'logged_time: ' + $logged_time.to_s
p 'lang: ' + $lang
