module SenderHelper
	DATE = Date.today

	STATION = {
	  minsk: '2100001',
	  pinsk: '2100180'
	}

	# set guid, logged_token, session, logged_time, lang headers to global variables
	def set_headers_from_response(response, session)
	  response['set-cookie'].split('; ').map do |cookie|
	    cookie = cookie.split(', ')[1] if cookie.include?("path")
	    next if cookie == nil

	    cookie_arr = cookie.split("=")

	    next if cookie_arr[-1] == 'deleted'

	    case cookie_arr[0]
	      when 'logged_token'
	        session.logged_token = cookie_arr[-1]
	      when 'logged_fname'
	        session.logged_fname = cookie_arr[-1]
	      when 'logged_lname'
	        session.logged_lname = cookie_arr[-1]
	      when 'logged_email'
	        session.logged_email = cookie_arr[-1]
	      when 'logged_time'
	        session.logged_time = cookie_arr[-1]
	      when 'session'
	        session.session = cookie_arr[-1]
	      when 'lang'
	        session.lang = cookie_arr[-1]
	      when 'guid'
	        session.guid = cookie_arr[-1]
	      when 'order_basket_id'
	        session.order_basket_id ||= cookie_arr[-1]
	    end
	  end
	end

	# smth wrong with guid
	def set_guid(request, session)
	  request["Cookie"] += " guid=0e1290a21dfb7c7ca1e5e4ba6ebae39f31281f35%7Eeec97b7775205bed52a399f6188f9b34"
	  #request["Cookie"] += " guid=#{session.guid}"
	end

	def set_date
	  DATE.to_s
	end

	def set_date_time
	  DateTime.new(DATE.year, DATE.month, DATE.day, 19, 52).to_time.to_i
	end

	def add_cookie_to_request(request, session)
	  request["Cookie"] = "session=#{session.session}; lang=#{session.lang};" 
	  request["Cookie"] += " logged_fname=#{session.logged_fname};" if session.logged_fname
	  request["Cookie"] += " logged_lname=#{session.logged_lname};" if session.logged_lname
	  request["Cookie"] += " logged_email=#{session.logged_email};" if session.logged_email
	  request["Cookie"] += " logged_token=#{session.logged_token};" if session.logged_token
	  request["Cookie"] += " logged_time=#{session.logged_time};" if session.logged_time
	  request["Cookie"] += " session=#{session.session};" if session.session
	end

	# Add common headers and return request object
	def add_headers_to_request(request)
	  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
	  request["Accept-Language"] = "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7"
	  request["Cache-Control"] = "max-age=0"
	  request["Connection"] = "keep-alive"
	  request["Sec-Fetch-Dest"] = "document"
	  request["Sec-Fetch-Mode"] = "navigate"
	  request["Sec-Fetch-Site"] = "cross-site"
	  request["Sec-Fetch-User"] = "?1"
	  request["Upgrade-Insecure-Requests"] = "1"
	  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
	  request["Sec-Ch-Ua"] = "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"100\", \"Google Chrome\";v=\"100\""
	  request["Sec-Ch-Ua-Mobile"] = "?0"
	  request["Sec-Ch-Ua-Platform"] = "\"macOS\""

	  request
	end

	# Set https
	def req_options(uri)
	  { use_ssl: uri.scheme == "https" }
	end

	# Send request and return response object
	def send_req(uri, request)
	  Net::HTTP.start(uri.hostname, uri.port, req_options(uri)) do |http|
	    http.request(request)
	  end
	end


	def form_second_ajax_request_params(free_places_hash)
	  car = free_places_hash["tariffs"][0]["cars"][0]

	  result = {
	    arrStationCode: STATION[:pinsk],
	    carriageInfos: [{
	      addSigns: "",
	      altTariff: 20.18,
	      carrier: car["carrier"],
	      freeSeats: car["emptyPlaces"].join(', '),
	      num: car["number"],
	      registrationAllowed: true,
	      saleOnTwo: car["saleOnTwo"],
	      serviceClassCode: "2К",
	      serviceClassIntCode: "",
	      subType: car["subType"],
	      tariff: 20.18,
	      typeCode: "К",
	      typeCodeShow: "К"
	    }],
	    countAdultPassengers: 1,
	    countChildrenPassengers: 0,
	    countFreePassengers: 0,
	    countSeats: 1,
	    depStationCode: STATION[:minsk],
	    departureDate: $date.to_s,
	    departureTime: "22:49",
	    orientation: "H",
	    train: "657Б",
	    width: 960
	  }.to_json.to_s
	end

	def set_passanger_data(request)
	  request.set_form_data({
	    :agreement => 2,
	    :last_name_1 => 'IVANOB',
	    :first_name_1 => 'IVAN',
	    :middle_name_1 => 'IVANOVICH',
	    :document_type_1 => 'ПБ',
	    :document_number_1 => 'МР1234567',
	    :passenger_type_1 => 'adult',
	    :passenger_id_1 => 1828930})
	end

	def form_data_for_passangers_request(free_places_hash, second)
	  car = free_places_hash["tariffs"][0]["cars"][0]
	  place = car["emptyPlaces"].first
	  place_i = place.to_i
	  top_or_bottom = place_i.even? ? "TOP" : "DOWN"
	  place_hash = { place => top_or_bottom }

	  result = {
	    places_adult: 1,
	    places_children: 0,
	    places_free: 0,
	    places: place_i,
	    places_with_types: place_hash,
	    places_with_gender: {},
	    places_cost: 20.18,
	    car_places: free_places_hash, 
	    car_details: second,
	    car_type: 4,
	    car_number: car["number"],
	    is_gender_coupe: false,
	    sale_on_two: false,
	    type_abbr: '2К',
	    type_abbr_int: '',
	    is_el_reg_possible: true,
	    uz: false,
	    sel_bedding: true
	  }.to_json.to_s
	end

end