# First unauthorized request to pass.rw.by, just to get session token 
def send_request_for_session_token(user)
  uri = URI.parse("https://pass.rw.by/en/")
  request = Net::HTTP::Get.new(uri)

  response = send_req(uri, request)
  set_headers_from_response(response, user)
end

# Login post request
# returns lang, logged_fname, logged_lname, logged_email, logged_token cookies
# and location header to http version(same url)
def send_first_post_request(user)
  uri = URI.parse("https://pass.rw.by/en/")
  request = Net::HTTP::Post.new(uri)

  request.set_form_data({:login => user.login, :password => user.password, :dologin => user.dologin})
  add_cookie_to_request(request, user)
  add_headers_to_request(request, user)

  response = send_req(uri, request)
  set_headers_from_response(response, user)
end

# Login get https request, return to us logged_time header
def send_third_get_request(user)
  uri = URI.parse("https://pass.rw.by/en/")
  request = Net::HTTP::Get.new(uri)

  add_cookie_to_request(request, user)
  add_headers_to_request(request, user)

  response = send_req(uri, request)
  set_headers_from_response(response, user)
end

# returns long params string about your route and free_seats(an example can be seen at the end of the method)
def get_route_params(user)
  choose_route_link = "https://pass.rw.by/en/route/?from=Minsk+Pasa%C5%BEyrski&from_exp=#{STATION[:minsk]}&from_esr=&to=Pinsk&to_exp=#{STATION[:pinsk]}&to_esr=133202&date=#{set_date}"
  uri = URI.parse(choose_route_link)
  request = Net::HTTP::Get.new(uri)

  add_cookie_to_request(request, user)
  add_headers_to_request(request, user)

  response = send_req(uri, request)
  set_headers_from_response(response, user)

  # parse hidden input with data
  # example:
  # <input class="js-sch-item-route" type="hidden" name="route" value="a:43:{s:5:"index";i:2;s:12:"is_main_from";s:1:"1";s:10:"is_main_to";s:1:"0";s:10:"train_type";s:21:"interregional_economy";s:13:"car_accessory";s:0:"";s:12:"train_number";s:5:"657Б";s:12:"train_thread";s:0:"";s:5:"title";s:32:"ПОЛОЦК - БРЕСТ ЦЕН";s:18:"title_station_from";s:12:"ПОЛОЦК";s:16:"title_station_to";s:17:"БРЕСТ ЦЕН";s:12:"from_station";s:7:"2100001";s:16:"from_station_exp";s:7:"2100001";s:15:"from_station_db";s:17:"Minsk Pasažyrski";s:9:"from_time";i:1651866540;s:10:"to_station";s:7:"2100180";s:14:"to_station_exp";s:7:"2100180";s:13:"to_station_db";s:5:"Pinsk";s:7:"to_time";i:1651887600;s:8:"duration";s:5:"05:51";s:16:"duration_minutes";i:351;s:12:"car_category";s:0:"";s:6:"places";a:2:{i:0;a:5:{s:8:"car_type";i:3;s:10:"free_seats";s:0:"";s:5:"price";s:0:"";s:10:"price_type";s:0:"";s:11:"price_multi";a:1:{i:0;a:5:{s:6:"places";i:93;s:6:"prices";a:1:{i:0;d:14.539999999999999;}s:12:"classservice";s:3:"3П";s:14:"tariff_service";d:3;s:11:"sel_bedding";b:1;}}}>
  product = Nokogiri::HTML(Curl.get(choose_route_link).body_str)
  attrs = product.xpath('//input[starts-with(@class, "js-sch-item-route")]')
  # add check, if attrs.attr("value").value returns error => maybe it cant find free seats, or smth wrong with rw.by
  unless attrs
    p 'check if button for buying exist'
    exit
  end
  attrs.attr("value").value
end

# returns to us guid after we send the long string from the previous method
def send_request_for_guid(params_for_request, user)
  uri = URI.parse("https://pass.rw.by/en/order/places/")
  request = Net::HTTP::Post.new(uri)

  add_cookie_to_request(request, user)
  add_headers_to_request(request, user)
  request.set_form_data({:route => params_for_request})

  response = send_req(uri, request)
  set_headers_from_response(response, user)
  response
end

# returns the train info and emptyPlaces
def send_ajax_req_for_free_places_hash(user)
  choose_type_of_carriage_link = "https://pass.rw.by/en/ajax/route/car_places/?from=#{STATION[:minsk]}&to=#{STATION[:pinsk]}&date=#{set_date}&train_number=657%D0%91&car_type=4&from_time=#{set_date_time}&_=#{Time.now.to_i.to_s + '000'}"
  uri = URI.parse(choose_type_of_carriage_link)
  request = Net::HTTP::Get.new(uri)
  request.content_type = "application/json"

  add_cookie_to_request(request, user)
  add_headers_to_request(request, user)
  set_guid(request, user)

  response = send_req(uri, request)
  set_headers_from_response(response, user)
  begin
    JSON.parse(response.body)
  rescue JSON::ParserError
    p 'JSON::ParserError'
  end


  # TODO: check if tariffs is empty

  # response example
  # {"isSimplePopup"=>false, "carType"=>"2-сl. sleeping compt.", "trainNumber"=>"657Б", "trainType"=>"interregional_economy", 
  # "isFastTrain"=>true, "trainType2"=>"СК", "from"=>"Polack", "to"=>"Brest Centraĺny", "fromCode"=>"2100001", "toCode"=>"2100180", 
  # "hideCarImage"=>false, "route"=>{"from"=>"Minsk Pasažyrski", "to"=>"Pinsk", "startDate"=>"05/06/2022", "startDateForRequest"=>"06.05.2022", 
  # "startTime"=>"22:49", "endDate"=>"05/07/2022", "endTime"=>"04:40", "timeInWay"=>"5 h 51 min", "trainDepDate"=>"2022-05-06", 
  # "startDateFormatted"=>"Fri, May 06", "hidden"=>false}, "allow_order"=>true, "tariffs"=>[{"price"=>"201 800", "price_byn"=>"20,18", "price2"=>"", 
  # "price_byn2"=>"", "typeAbbr"=>"2К", "typeAbbrPostfix"=>"", "isBicycle"=>false, "type"=>"2-сl. sleeping compt. (2К)", "typeAbbrInt"=>"", 
  # "description"=>"Car type – 2-сl. sleeping compt.<br />4-bed compartments. Seating capacity: up to 40<br />Service class – 2К 2-сl. sleeping compt. (no services)", 
  # "sign"=>"", "is_car_for_disabled"=>false, "uz"=>false, "isElRegPossible"=>true, "tariff_service"=>3, "sel_bedding"=>true, "cars"=>[{"number"=>"02", "subType"=>"66К", 
  # "carrier"=>"БЧ", "owner"=>"БЧ /БЧ", "emptyPlaces"=>["034"], "hideLegend"=>true, "imgSrc"=>"/media/i/vagons/kupe.png", "hash"=>"49532A05A3EAB96B467C9F5C62749D68", 
  # "noSmoking"=>false, "addSigns"=>"", "saleOnTwo"=>false, "trainLetter"=>"Б", "classServiceInt"=>"", "typeShow"=>"Купе", "ticket_selling_allowed"=>true, "isElRegPossible"=>true, 
  # "sel_bedding"=>true, "upperPlaces"=>1, "lowerPlaces"=>0, "totalPlacesHide"=>true, "totalPlaces"=>1}, {"number"=>"06", "subType"=>"66К", 
  # "carrier"=>"БЧ", "owner"=>"БЧ /БЧ", "emptyPlaces"=>["010"], "hideLegend"=>true, "imgSrc"=>"/media/i/vagons/kupe.png", "hash"=>"A9B79176C1D8BADF9884676656633BE2", 
  # "noSmoking"=>false, "addSigns"=>"", "saleOnTwo"=>false, "trainLetter"=>"Б", "classServiceInt"=>"", "typeShow"=>"Купе", "ticket_selling_allowed"=>true, 
  # "isElRegPossible"=>true, "sel_bedding"=>true, "upperPlaces"=>1, "lowerPlaces"=>0, "totalPlacesHide"=>true, "totalPlaces"=>1}], "price_rub"=>"525,29", 
  # "price_eur"=>"7,47", "price_usd"=>"7,92", "price_rub2"=>"", "price_eur2"=>"", "price_usd2"=>""}]}
end

# returns the location of seats in the train by pixels
def send_ajax_req_for_train_pixels(free_places_hash, user)
  uri = URI.parse("https://pass.rw.by/en/ajax/sppd4/v1/carriages/graphic/?user_key=c11f8d06e3e1594815b9c4ebaddf19a0")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"

  add_cookie_to_request(request, user)
  add_headers_to_request(request, user)
  set_guid(request, user)
  request.body = form_second_ajax_request_params(free_places_hash)

  response = send_req(uri, request)

  set_headers_from_response(response, user)
  begin
    JSON.parse(response.body)[0]
  rescue JSON::ParserError
    p 'JSON::ParserError'
  end
end 

def send_request_with_seat_info(free_places_hash, second_ajax_resp, user)
  uri = URI.parse("https://pass.rw.by/en/order/passengers/")
  request = Net::HTTP::Post.new(uri)

  request.body = form_data_for_passangers_request(free_places_hash, second_ajax_resp)
  add_cookie_to_request(request, user)
  set_guid(request, user)
  request.content_type = "application/x-www-form-urlencoded"
  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
  request["Accept-Language"] = "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7"
  request["Cache-Control"] = "max-age=0"
  request["Connection"] = "keep-alive"
  request["Origin"] = "https://pass.rw.by"
  request["Referer"] = "https://pass.rw.by/en/order/places/"
  request["Sec-Fetch-Dest"] = "document"
  request["Sec-Fetch-Mode"] = "navigate"
  request["Sec-Fetch-Site"] = "same-origin"
  request["Sec-Fetch-User"] = "?1"
  request["Upgrade-Insecure-Requests"] = "1"
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36"
  request["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"111\", \"Not(A:Brand\";v=\"8\", \"Chromium\";v=\"111\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["Sec-Ch-Ua-Platform"] = "\"macOS\""


  response = send_req(uri, request)
  set_headers_from_response(response, user)
  response
end

# Send last request with user info(first-middle-last names, passport data, etc)
def send_passanger_info(user)
  uri = URI.parse("https://pass.rw.by/en/order/passengers/")
  request = Net::HTTP::Post.new(uri)

  set_passanger_data(request)
  add_cookie_to_request(request, user)
  set_guid(request, user)

  request.content_type = "application/x-www-form-urlencoded"
  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
  request["Accept-Language"] = "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7"
  request["Cache-Control"] = "max-age=0"
  request["Connection"] = "keep-alive"
  request["Origin"] = "https://pass.rw.by"
  request["Referer"] = "https://pass.rw.by/en/order/passengers/"
  request["Sec-Fetch-Dest"] = "document"
  request["Sec-Fetch-Mode"] = "navigate"
  request["Sec-Fetch-Site"] = "same-origin"
  request["Sec-Fetch-User"] = "?1"
  request["Upgrade-Insecure-Requests"] = "1"
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36"
  request["Sec-Ch-Ua"] = "\"Google Chrome\";v=\"111\", \"Not(A:Brand\";v=\"8\", \"Chromium\";v=\"111\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["Sec-Ch-Ua-Platform"] = "\"macOS\""

  response = send_req(uri, request)
  set_headers_from_response(response, user)

  response
end

# Should check if the ticket has appeared in the backet or not(dont work right now)
def send_orders_request(user)
  uri = URI.parse("https://pass.rw.by/en/order/payment/")
  request = Net::HTTP::Get.new(uri)

  add_headers_to_request(request, user)

  response = send_req(uri, request)
  set_headers_from_response(response, user)
end