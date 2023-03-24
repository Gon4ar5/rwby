require 'spec_helper'
require 'net/http'
require 'uri'
require 'openssl'
require 'yaml'
require 'xpath'
require 'curb'
require 'nokogiri'
require 'date'
require 'json'

require './user.rb'
require_relative '../sender'
require_relative '../helper'

describe 'requests' do
  let(:user) { User.new }
  
  # First unauthorized request to pass.rw.by, just to get session token 
  context '#send_req_for_session_token' do
    
    it 'should set up some cookie' do
      send_req_for_session_token(user)

      expect(user.session).not_to be_nil
      expect(user.lang).to be_eql 'da9292dd5d6e1b00ab52e48770777e5a26c6a263%7Een'
    end
  end

  # Login post request
  context '#send_first_post_req' do
    it 'should set up cookie' do
      send_req_for_session_token(user)
      cookie = send_first_post_req(user)

      expect(user.session).not_to be_nil
      expect(cookie).not_to be_nil
    end
  end

  # # Login get https request, return to us logged_time header
  context '#send_third_get_req' do
    it 'should set up logged_time header' do
      send_req_for_session_token(user)
      cookie = send_first_post_req(user)
      send_second_get_req(cookie, user)
      send_third_get_req(cookie, user)

      expect(user.session).not_to be_nil
    end
  end

  # Returns long params string about your route and free_seats(an example can be seen at the end of the method)
  # <input class="js-sch-item-route" 
  #  type="hidden" 
  #  name="route" 
  #  value="a:43:{s:5:"index";i:2;s:12:"is_main_from";s:1:"1";s:10:"is_main_to";s:1:"0";s:10:"train_type";s:21:"interregional_economy";s:13:"car_accessory";s:0:"";s:12:"train_number";s:5:"657Б";s:12:"train_thread";s:0:"";s:5:"title";s:32:"ПОЛОЦК - БРЕСТ ЦЕН";s:18:"title_station_from";s:12:"ПОЛОЦК";s:16:"title_station_to";s:17:"БРЕСТ ЦЕН";s:12:"from_station";s:7:"2100001";s:16:"from_station_exp";s:7:"2100001";s:15:"from_station_db";s:17:"Minsk Pasažyrski";s:9:"from_time";i:1651866540;s:10:"to_station";s:7:"2100180";s:14:"to_station_exp";s:7:"2100180";s:13:"to_station_db";s:5:"Pinsk";s:7:"to_time";i:1651887600;s:8:"duration";s:5:"05:51";s:16:"duration_minutes";i:351;s:12:"car_category";s:0:"";s:6:"places";a:2:{i:0;a:5:{s:8:"car_type";i:3;s:10:"free_seats";s:0:"";s:5:"price";s:0:"";s:10:"price_type";s:0:"";s:11:"price_multi";a:1:{i:0;a:5:{s:6:"places";i:93;s:6:"prices";a:1:{i:0;d:14.539999999999999;}s:12:"classservice";s:3:"3П";s:14:"tariff_service";d:3;s:11:"sel_bedding";b:1;}}}>
  context '#get_route_params' do
    it 'should return response with value' do
      send_req_for_session_token(user)
      cookie = send_first_post_req(user)
      send_second_get_req(cookie, user)
      send_third_get_req(cookie, user)
      params_for_request = get_route_params(user)

      expect(params_for_request).not_to be_nil
      expect(params_for_request).to be_an_instance_of(String)
    end
  end

  # Returns to us guid after we send the long string from the previous method
  context '#send_request_for_guid' do
    it 'should return guid' do
      send_req_for_session_token(user)
      cookie = send_first_post_req(user)
      send_second_get_req(cookie, user)
      send_third_get_req(cookie, user)
      params_for_request = get_route_params(user)
      send_request_for_guid(params_for_request, user)

      expect(user.guid).not_to be_nil
    end
  end

  # # Returns the train info and emptyPlaces
  # # response example
  # # {"isSimplePopup"=>false, "carType"=>"2-сl. sleeping compt.", "trainNumber"=>"657Б", "trainType"=>"interregional_economy", 
  # # "isFastTrain"=>true, "trainType2"=>"СК", "from"=>"Polack", "to"=>"Brest Centraĺny", "fromCode"=>"2100001", "toCode"=>"2100180", 
  # # "hideCarImage"=>false, "route"=>{"from"=>"Minsk Pasažyrski", "to"=>"Pinsk", "startDate"=>"05/06/2022", "startDateForRequest"=>"06.05.2022", 
  # # "startTime"=>"22:49", "endDate"=>"05/07/2022", "endTime"=>"04:40", "timeInWay"=>"5 h 51 min", "trainDepDate"=>"2022-05-06", 
  # # "startDateFormatted"=>"Fri, May 06", "hidden"=>false}, "allow_order"=>true, "tariffs"=>[{"price"=>"201 800", "price_byn"=>"20,18", "price2"=>"", 
  # # "price_byn2"=>"", "typeAbbr"=>"2К", "typeAbbrPostfix"=>"", "isBicycle"=>false, "type"=>"2-сl. sleeping compt. (2К)", "typeAbbrInt"=>"", 
  # # "description"=>"Car type – 2-сl. sleeping compt.<br />4-bed compartments. Seating capacity: up to 40<br />Service class – 2К 2-сl. sleeping compt. (no services)", 
  # # "sign"=>"", "is_car_for_disabled"=>false, "uz"=>false, "isElRegPossible"=>true, "tariff_service"=>3, "sel_bedding"=>true, "cars"=>[{"number"=>"02", "subType"=>"66К", 
  # # "carrier"=>"БЧ", "owner"=>"БЧ /БЧ", "emptyPlaces"=>["034"], "hideLegend"=>true, "imgSrc"=>"/media/i/vagons/kupe.png", "hash"=>"49532A05A3EAB96B467C9F5C62749D68", 
  # # "noSmoking"=>false, "addSigns"=>"", "saleOnTwo"=>false, "trainLetter"=>"Б", "classServiceInt"=>"", "typeShow"=>"Купе", "ticket_selling_allowed"=>true, "isElRegPossible"=>true, 
  # # "sel_bedding"=>true, "upperPlaces"=>1, "lowerPlaces"=>0, "totalPlacesHide"=>true, "totalPlaces"=>1}, {"number"=>"06", "subType"=>"66К", 
  # # "carrier"=>"БЧ", "owner"=>"БЧ /БЧ", "emptyPlaces"=>["010"], "hideLegend"=>true, "imgSrc"=>"/media/i/vagons/kupe.png", "hash"=>"A9B79176C1D8BADF9884676656633BE2", 
  # # "noSmoking"=>false, "addSigns"=>"", "saleOnTwo"=>false, "trainLetter"=>"Б", "classServiceInt"=>"", "typeShow"=>"Купе", "ticket_selling_allowed"=>true, 
  # # "isElRegPossible"=>true, "sel_bedding"=>true, "upperPlaces"=>1, "lowerPlaces"=>0, "totalPlacesHide"=>true, "totalPlaces"=>1}], "price_rub"=>"525,29", 
  # # "price_eur"=>"7,47", "price_usd"=>"7,92", "price_rub2"=>"", "price_eur2"=>"", "price_usd2"=>""}]}
  context '#send_ajax_req_for_free_places_hash' do
    it 'should return response with all data in json' do
      send_req_for_session_token(user)
      cookie = send_first_post_req(user)
      send_second_get_req(cookie, user)
      send_third_get_req(cookie, user)
      params_for_request = get_route_params(user)
      send_request_for_guid(params_for_request, user)
      free_places_hash = send_ajax_req_for_free_places_hash(user)

      # no seats in this carriage
      expect(free_places_hash).not_to be_nil
      expect(free_places_hash["tariffs"]).not_to be_nil
      expect(free_places_hash["tariffs"][0]).not_to be_nil
      expect(free_places_hash["tariffs"][0]["cars"]).not_to be_nil
      expect(free_places_hash["tariffs"][0]["cars"][0]).not_to be_nil
      expect(free_places_hash["trainNumber"]).to be_eql "657Б"
      expect(free_places_hash).to be_an_instance_of(Hash)
    end
  end

  # # Returns the location of seats in the train by pixels
  context '#send_ajax_req_for_train_pixels' do
    it 'should return json with info about pixels' do
      send_req_for_session_token(user)
      cookie = send_first_post_req(user)
      send_second_get_req(cookie, user)
      send_third_get_req(cookie, user)
      params_for_request = get_route_params(user)
      send_request_for_guid(params_for_request, user)
      free_places_hash = send_ajax_req_for_free_places_hash(user)
      second_ajax_resp = send_ajax_req_for_train_pixels(free_places_hash, user)

      expect(free_places_hash).not_to be_nil
      expect(free_places_hash["trainNumber"]).to be_eql "657Б"
      expect(free_places_hash).to be_an_instance_of(Hash)
    end
  end
  
  # Send all info about train, seats and your seat
  context '#send_request_with_seat_info' do
    # idk how to set up guid
  end

  # # Send last request with user info(first-middle-last names, passport data, etc)
  # context '#send_passanger_info' do
  #   it 'qwe' do
  #     expect(send_passanger_info).to eq 1
  #   end
  # end

  # # Should check if the ticket has appeared in the backet or not(dont work right now)
  # context '#send_orders_request' do
  #   it 'qwe' do
  #     expect(send_orders_request).to eq 1
  #   end
  # end
end