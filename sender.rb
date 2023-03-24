# First unauthorized request to pass.rw.by, just to get session token 
def send_req_for_session_token(user)
  uri = URI.parse("https://pass.rw.by/en/")
  request = Net::HTTP::Get.new(uri)
  response = send_req(uri, request)

  set_headers_from_response(response, user)
end

# Login post request
# returns lang, logged_fname, logged_lname, logged_email, logged_token cookies
# and location header to http version(same url)
def send_first_post_req(user)
  uri = URI.parse("https://pass.rw.by/en/")
  request = Net::HTTP::Post.new(uri)

  request.content_type = "application/x-www-form-urlencoded"
  request.set_form_data('login' => user.login, 'password' => user.password, 'dologin' => user.dologin)
  add_default_headers(request, user)

  response = send_req(uri, request)

  set_headers_from_response(response, user)

  parse_cookie(response, user)
end

# Login get http request, I don’t know why I’m sending it, but for clarity I’ll do it
def send_second_get_req(cookie, user)
  uri = URI.parse("http://pass.rw.by/en/?path=en%2F&")
  request = Net::HTTP::Get.new(uri)

  add_default_headers(request, user)
  request["Cookie"] = cookie

  # I didn't call send_req here, cause here we need to use http instead of https
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end
end

# Login get https request, return to us logged_time header
def send_third_get_req(cookie, user)
  uri = URI.parse("https://pass.rw.by/en/?path=en%2F&")
  request = Net::HTTP::Get.new(uri)

  add_default_headers(request, user)
  request["Cookie"] = cookie

  response = send_req(uri, request)
  set_headers_from_response(response, user)
end

# returns long params string about your route and free_seats(an example can be seen at the end of the method)
def get_route_params(user)
  # nice url, i have no idea why they added ž to Pasažyrski in english
  # all params are static, except front_date and date
  choose_route_link = "https://pass.rw.by/en/route/?from=Minsk+Pasa%C5%BEyrski&from_exp=2100001&from_esr=&to=Pinsk&to_exp=2100180&to_esr=133202&front_date=today&date=today"
  uri = URI.parse(choose_route_link)
  request = Net::HTTP::Get.new(uri)

  add_default_headers(request, user)
  request["Referer"] = "https://pass.rw.by/en/"
  #request["Cookie"] = "lang=a99e6f9df71a6809253b6a85825dec8e3130af73%7Een; session=b4s9danl3h4706nlqrjgufaq01; logged_fname=258126e822268ded36188f474197e561e7fbf34e%7Etupoe; logged_lname=48c78a9d61a206a3ec7fb4eff1429256359dce9e%7Eeblo; logged_email=c76f46899cd68a708c8021b0b6520b1969fdf213%7Eeblo-tupoe1488%40mail.ru; logged_token=f404179be803da00ffbd03dfccf42a2f7dbf8e4f%7EeyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwidXNlciI6eyJpZCI6MTQ5MjYxOSwiZW1haWwiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwibGFuZ3VhZ2UiOiJlbiJ9LCJhdXRoIjpbeyJhdXRob3JpdHkiOiJST0xFX1UifV0sImlhdCI6MTY1MDkxMzQ1NCwiZXhwIjoxNjUxNzc3NDU0fQ.j08are2tbnx8ol_ka6TI_yYwQH9x__yhAor5MSz8jy4WmhJaK-e4cLZpOl6ETnzZU_VNvO3z0jvA7Ca8MH73WA5M_u-KGSFO9yn1uh1Lcxn_dxW_4aZQFlHc6okNduZwvmVa2pebe1B_V1Ep-LG4OqwN_VP6-R2umjpw-ABXmHoCQiYBlfXY-yWTPfkPBo-VB5KwasGB0XhMZxqd_kdUAu_Kw32qd-OVgq3UzWoQBzpzorC7khf_SCP-egx-m1EQCDjSO8gJXuEgNBl9lu0dbJjxxptUtdRGTeiYxSvkhOwSUynZHaqAEbU4IlVCNrN99b65XAWRFLocFVoAYIgVlA; logged_time=fa762962e79371c96b5883aab11fbe61a56bc63f%7E1650913587"
  set_request_cookie_header(request, user)

  response = send_req(uri, request)

  set_headers_from_response(response, user)

  # parse hidden input with data
  # example:
  # <input class="js-sch-item-route" type="hidden" name="route" value="a:43:{s:5:"index";i:2;s:12:"is_main_from";s:1:"1";s:10:"is_main_to";s:1:"0";s:10:"train_type";s:21:"interregional_economy";s:13:"car_accessory";s:0:"";s:12:"train_number";s:5:"657Б";s:12:"train_thread";s:0:"";s:5:"title";s:32:"ПОЛОЦК - БРЕСТ ЦЕН";s:18:"title_station_from";s:12:"ПОЛОЦК";s:16:"title_station_to";s:17:"БРЕСТ ЦЕН";s:12:"from_station";s:7:"2100001";s:16:"from_station_exp";s:7:"2100001";s:15:"from_station_db";s:17:"Minsk Pasažyrski";s:9:"from_time";i:1651866540;s:10:"to_station";s:7:"2100180";s:14:"to_station_exp";s:7:"2100180";s:13:"to_station_db";s:5:"Pinsk";s:7:"to_time";i:1651887600;s:8:"duration";s:5:"05:51";s:16:"duration_minutes";i:351;s:12:"car_category";s:0:"";s:6:"places";a:2:{i:0;a:5:{s:8:"car_type";i:3;s:10:"free_seats";s:0:"";s:5:"price";s:0:"";s:10:"price_type";s:0:"";s:11:"price_multi";a:1:{i:0;a:5:{s:6:"places";i:93;s:6:"prices";a:1:{i:0;d:14.539999999999999;}s:12:"classservice";s:3:"3П";s:14:"tariff_service";d:3;s:11:"sel_bedding";b:1;}}}>
  product = Nokogiri::HTML(Curl.get(choose_route_link).body_str)
  attrs = product.xpath('//input[starts-with(@class, "js-sch-item-route")]')
  attrs.attr("value").value
end

# returns to us guid after we send the long string from the previous method
def send_request_for_guid(params_for_request, user)
  uri = URI.parse("https://pass.rw.by/en/order/places/")
  request = Net::HTTP::Post.new(uri)

  request.content_type = "application/x-www-form-urlencoded"
  add_default_headers(request, user)
  request["Origin"] = "https://pass.rw.by"
  request["Referer"] = "https://pass.rw.by/en/route/?from=Minsk+Pasa%C5%BEyrski&from_exp=2100001&from_esr=&to=Pinsk&to_exp=2100180&to_esr=133202&front_date=today&date=today"
  #request["Cookie"] = "lang=a99e6f9df71a6809253b6a85825dec8e3130af73%7Een; session=b4s9danl3h4706nlqrjgufaq01; logged_fname=258126e822268ded36188f474197e561e7fbf34e%7Etupoe; logged_lname=48c78a9d61a206a3ec7fb4eff1429256359dce9e%7Eeblo; logged_email=c76f46899cd68a708c8021b0b6520b1969fdf213%7Eeblo-tupoe1488%40mail.ru; logged_token=f404179be803da00ffbd03dfccf42a2f7dbf8e4f%7EeyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwidXNlciI6eyJpZCI6MTQ5MjYxOSwiZW1haWwiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwibGFuZ3VhZ2UiOiJlbiJ9LCJhdXRoIjpbeyJhdXRob3JpdHkiOiJST0xFX1UifV0sImlhdCI6MTY1MDkxMzQ1NCwiZXhwIjoxNjUxNzc3NDU0fQ.j08are2tbnx8ol_ka6TI_yYwQH9x__yhAor5MSz8jy4WmhJaK-e4cLZpOl6ETnzZU_VNvO3z0jvA7Ca8MH73WA5M_u-KGSFO9yn1uh1Lcxn_dxW_4aZQFlHc6okNduZwvmVa2pebe1B_V1Ep-LG4OqwN_VP6-R2umjpw-ABXmHoCQiYBlfXY-yWTPfkPBo-VB5KwasGB0XhMZxqd_kdUAu_Kw32qd-OVgq3UzWoQBzpzorC7khf_SCP-egx-m1EQCDjSO8gJXuEgNBl9lu0dbJjxxptUtdRGTeiYxSvkhOwSUynZHaqAEbU4IlVCNrN99b65XAWRFLocFVoAYIgVlA; logged_time=7844dbce6a513ce859113536b59081318384e079%7E1650913595"
  set_request_cookie_header(request, user)

  request.set_form_data('route' => params_for_request)

  response = send_req(uri, request)

  set_headers_from_response(response, user)
  response
end

# returns the train info and emptyPlaces
def send_ajax_req_for_free_places_hash(user)
  choose_type_of_carriage_link = "https://pass.rw.by/en/ajax/route/car_places/?from=#{STATION[:minsk]}&to=#{STATION[:pinsk]}&date=#{Date.today.to_s}&train_number=657%D0%91&car_type=4&from_time=#{DateTime.new(Date.today.year, Date.today.month, Date.today.day, 19, 49).to_time.to_i}&_=#{Time.now.to_i}"
  uri = URI.parse(choose_type_of_carriage_link)
  request = Net::HTTP::Get.new(uri)

  request.content_type = "application/json"
  add_default_headers(request, user, add_addtl_headers: true)
  request["Accept"] = "*/*"
  #request["Cookie"] = "lang=a99e6f9df71a6809253b6a85825dec8e3130af73%7Een; session=b4s9danl3h4706nlqrjgufaq01; logged_fname=258126e822268ded36188f474197e561e7fbf34e%7Etupoe; logged_lname=48c78a9d61a206a3ec7fb4eff1429256359dce9e%7Eeblo; logged_email=c76f46899cd68a708c8021b0b6520b1969fdf213%7Eeblo-tupoe1488%40mail.ru; logged_token=f404179be803da00ffbd03dfccf42a2f7dbf8e4f%7EeyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwidXNlciI6eyJpZCI6MTQ5MjYxOSwiZW1haWwiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwibGFuZ3VhZ2UiOiJlbiJ9LCJhdXRoIjpbeyJhdXRob3JpdHkiOiJST0xFX1UifV0sImlhdCI6MTY1MDkxMzQ1NCwiZXhwIjoxNjUxNzc3NDU0fQ.j08are2tbnx8ol_ka6TI_yYwQH9x__yhAor5MSz8jy4WmhJaK-e4cLZpOl6ETnzZU_VNvO3z0jvA7Ca8MH73WA5M_u-KGSFO9yn1uh1Lcxn_dxW_4aZQFlHc6okNduZwvmVa2pebe1B_V1Ep-LG4OqwN_VP6-R2umjpw-ABXmHoCQiYBlfXY-yWTPfkPBo-VB5KwasGB0XhMZxqd_kdUAu_Kw32qd-OVgq3UzWoQBzpzorC7khf_SCP-egx-m1EQCDjSO8gJXuEgNBl9lu0dbJjxxptUtdRGTeiYxSvkhOwSUynZHaqAEbU4IlVCNrN99b65XAWRFLocFVoAYIgVlA; guid=654d01ab4f3357d7c618d706c7bba6b0d3ad1bf8%7E62aacb8e12afde1443b85750d4bba5a4; logged_time=3843a6ebc6d16dbf1650fc9d4e6d3e8eca3dd76f%7E1650913751"
  set_request_cookie_header(request, user)

  response = send_req(uri, request)

  set_headers_from_response(response, user)
  JSON.parse(response.body)
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
  link = "https://pass.rw.by/en/ajax/sppd4/v1/carriages/graphic/?user_key=c11f8d06e3e1594815b9c4ebaddf19a0"

  uri = URI.parse(link)
  request = Net::HTTP::Post.new(uri)

  request.content_type = "application/json"
  add_default_headers(request, user, add_addtl_headers: true)
  #request["Cookie"] = "session=6mggoe2e562h2nd7t67hlifc15; lang=27861e25c011d37999f31a93462f7008059d808d%7Een; logged_fname=ef7cca545ad21056a0cf2fe1f1a7da3ac9d02ea2%7Etupoe; logged_lname=96662128694b402f6c526b8c47711a5272097777%7Eeblo; logged_email=a1dd2dbe231ae465e4d0ffdf8e6155b162c25552%7Eeblo-tupoe1488%40mail.ru; logged_token=8364ae99c316f845c3e0324205478facc8debc99%7EeyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwidXNlciI6eyJpZCI6MTQ5MjYxOSwiZW1haWwiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwibGFuZ3VhZ2UiOiJlbiJ9LCJhdXRoIjpbeyJhdXRob3JpdHkiOiJST0xFX1UifV0sImlhdCI6MTY1MDIxMTQzNiwiZXhwIjoxNjUxMDc1NDM2fQ.Gc6QEANIOhJBUJJ31AcKXAZ5is57cFmPKTiRzgEhHs9j8Gl038B05oar4r-ElOsu6RMQaeRBjRjtVVvJeCUePPn3js72Ru-VclgwsY4lwAb8ev1XdV10zVZ1jZi0xBLhsZIQp-D9pGPpdUqe6tK0Zhs5VS9xBe_n5pmGuZaT6nIyzk2synGx1DBfTYo8ypKDMd7LiHHskrrLgbUhcSg6MqACSLHtpAZmrpEoi1uhxTA3ebOofEdALtGkNUSRSaXoGq6dhiCdjBU-ZS1WiwjTMxtBVJ-zNPro4fkCMc_v8NF44EvoOFEVbZdkVJ6DJilsJ2jcepShJT4g4IpzEL5ZXw; guid=d81fd68a1e6beccf9f0a9910e7702cb216b88be0%7E44fb26d77fb8a80ad4f5cc7dd8512f6b; logged_time=15de7426a04d54a4cb4ed4f069a47cc308ab6e1f%7E1650211446"
  set_request_cookie_header(request, user)

  request.body = form_second_ajax_request_params(free_places_hash)

  response = send_req(uri, request)

  set_headers_from_response(response, user)
  JSON.parse(response.body)[0]
end 

# Send all info about train, seats and your seat
# They send me the wrong guid, so this request doesnt work
def send_request_with_seat_info(free_places_hash, second, user)
  uri = URI.parse("https://pass.rw.by/en/order/passengers/")
  request = Net::HTTP::Post.new(uri)

  request.content_type = "text/html; charset=utf-8"
  add_default_headers(request, user, add_addtl_headers: true)

  set_request_cookie_header(request, user, guid_required: true)

  # set up all information for the request body
  request.body = form_data_for_passangers_request(free_places_hash, second)
  response = send_req(uri, request)

  set_headers_from_response(response, user)

  File.write('./html/seats_info.html', response.body)
  #p response.body
  response
end

# Send last request with user info(first-middle-last names, passport data, etc)
def send_passanger_info(user)
  link = 'https://pass.rw.by/en/order/passengers/'

  uri = URI.parse(link)
  request = Net::HTTP::Post.new(uri)

  request.content_type = "application/x-www-form-urlencoded"
  add_default_headers(request, user)
  request["Origin"] = "https://pass.rw.by"
  request["Referer"] = "https://pass.rw.by/en/order/passengers/"
  #request["Cookie"] = "lang=a99e6f9df71a6809253b6a85825dec8e3130af73%7Een; session=b4s9danl3h4706nlqrjgufaq01; logged_fname=258126e822268ded36188f474197e561e7fbf34e%7Etupoe; logged_lname=48c78a9d61a206a3ec7fb4eff1429256359dce9e%7Eeblo; logged_email=c76f46899cd68a708c8021b0b6520b1969fdf213%7Eeblo-tupoe1488%40mail.ru; logged_token=f404179be803da00ffbd03dfccf42a2f7dbf8e4f%7EeyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwidXNlciI6eyJpZCI6MTQ5MjYxOSwiZW1haWwiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwibGFuZ3VhZ2UiOiJlbiJ9LCJhdXRoIjpbeyJhdXRob3JpdHkiOiJST0xFX1UifV0sImlhdCI6MTY1MDkxMzQ1NCwiZXhwIjoxNjUxNzc3NDU0fQ.j08are2tbnx8ol_ka6TI_yYwQH9x__yhAor5MSz8jy4WmhJaK-e4cLZpOl6ETnzZU_VNvO3z0jvA7Ca8MH73WA5M_u-KGSFO9yn1uh1Lcxn_dxW_4aZQFlHc6okNduZwvmVa2pebe1B_V1Ep-LG4OqwN_VP6-R2umjpw-ABXmHoCQiYBlfXY-yWTPfkPBo-VB5KwasGB0XhMZxqd_kdUAu_Kw32qd-OVgq3UzWoQBzpzorC7khf_SCP-egx-m1EQCDjSO8gJXuEgNBl9lu0dbJjxxptUtdRGTeiYxSvkhOwSUynZHaqAEbU4IlVCNrN99b65XAWRFLocFVoAYIgVlA; guid=654d01ab4f3357d7c618d706c7bba6b0d3ad1bf8%7E62aacb8e12afde1443b85750d4bba5a4; logged_time=1d47c90c813419ff7dd1b5f04481f0a4d87d95f3%7E1650913874"
  set_request_cookie_header(request, user, guid_required: true)

  # set user info(first-middle-last names, passport data, etc)
  set_passanger_data(request)

  response = send_req(uri, request)

  File.write('./html/passengers_info.html', response.body)
end

# Should check if the ticket has appeared in the backet or not(dont work right now)
def send_orders_request(user)
  uri = URI.parse("https://pass.rw.by/en/order/payment/")
  request = Net::HTTP::Get.new(uri)

  add_default_headers(request, user)
  request["Referer"] = "https://pass.rw.by/en/?path=en%2F"
  set_request_cookie_header(request, user)

  response = send_req(uri, request)

  set_headers_from_response(response, user)
end