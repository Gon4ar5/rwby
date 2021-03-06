STATION = {
  minsk: '2100001',
  pinsk: '2100180'
}

# set guid, logged_token, session, logged_time, lang headers to global variables
def set_headers_from_response(response)
  response['set-cookie'].split('; ').map do |cookie|
    cookie = cookie.split(', ')[1] if cookie.include?("path")
    next if cookie == nil

    cookie_arr = cookie.split("=")
    $logged_token ||= cookie_arr[-1] if cookie_arr[0] == 'logged_token' && cookie_arr[-1] != 'deleted'
    $logged_fname ||= cookie_arr[-1] if cookie_arr[0] == 'logged_fname'
    $logged_lname ||= cookie_arr[-1] if cookie_arr[0] == 'logged_lname'
    $logged_email ||= cookie_arr[-1] if cookie_arr[0] == 'logged_email'
    $logged_time = cookie_arr[-1] if cookie_arr[0] == 'logged_time'
    $session ||= cookie_arr[-1] if cookie_arr[0] == 'session'
    $lang ||= cookie_arr[-1] if cookie_arr[0] == 'lang'
    $guid ||= cookie_arr[-1] if cookie_arr[0] == 'guid'
  end
end

# sets and returns cookies for each request
def set_request_cookie_header(request, guid_required: false)
  request["Cookie"] = "lang=#{$lang};"
  request["Cookie"] += " logged_fname=#{$logged_fname};" if $logged_fname
  request["Cookie"] += " logged_lname=#{$logged_lname};" if $logged_lname
  request["Cookie"] += " logged_email=#{$logged_email};" if $logged_email
  request["Cookie"] += " logged_token=#{$logged_token};" if $logged_token
  request["Cookie"] += " logged_time=#{$logged_time};" if $logged_time
  request["Cookie"] += " session=#{$session};" if $session

  request["Cookie"] += request["Cookie"] + " guid=#{$guid};" if guid_required

  request["Cookie"]
end

# Add common headers and return request object
def add_default_headers(request, add_addtl_headers: nil)
  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
  request["Accept-Language"] = "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7"
  request["Cache-Control"] = "max-age=0"
  request["Connection"] = "keep-alive"
  request["Cookie"] = "session=#{$session}; lang=#{$lang};" 
  request["Sec-Fetch-Dest"] = "document"
  request["Sec-Fetch-Mode"] = "navigate"
  request["Sec-Fetch-Site"] = "cross-site"
  request["Sec-Fetch-User"] = "?1"
  request["Upgrade-Insecure-Requests"] = "1"
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
  request["Sec-Ch-Ua"] = "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"100\", \"Google Chrome\";v=\"100\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["Sec-Ch-Ua-Platform"] = "\"macOS\""

  add_additional_headers(request) if add_addtl_headers

  request
end

def add_additional_headers(request)
  request["Accept"] = "application/json, text/javascript, */*; q=0.01"
  request["Origin"] = "https://pass.rw.by"
  request["Referer"] = "https://pass.rw.by/en/order/places/"
  request["Sec-Fetch-Dest"] = "empty"
  request["Sec-Fetch-Mode"] = "cors"
  request["Sec-Fetch-Site"] = "same-origin"
  request["X-Requested-With"] = "XMLHttpRequest"

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
    arrStationCode: STATION["pinsk"],
    carriageInfos: [{
      addSigns: "",
      altTariff: 20.18,
      carrier: car["carrier"],
      freeSeats: car["emptyPlaces"].join(', '),
      num: car["number"],
      registrationAllowed: true,
      saleOnTwo: car["saleOnTwo"],
      serviceClassCode: "2??",
      serviceClassIntCode: "",
      subType: car["subType"],
      tariff: 20.18,
      typeCode: "??",
      typeCodeShow: "??"
    }],
    countAdultPassengers: 1,
    countChildrenPassengers: 0,
    countFreePassengers: 0,
    countSeats: 1,
    depStationCode: STATION["minsk"],
    departureDate: Date.today.to_s,
    departureTime: "22:49",
    orientation: "H",
    train: "657??",
    width: 960
  }.to_json.to_s
end

def set_passanger_data(request)
  request.set_form_data(
    'agreement' => 2,
    'last_name_1': 'IVANOB',
    'first_name_1': 'IVAN',
    'middle_name_1': 'IVANOVICH',
    'document_type_1': '????',
    'document_number_1': '????1234567',
    'passenger_type_1': 'adult',
    'passenger_id_1': 1828930)
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
    car_type: 6,
    car_number: car["number"],
    is_gender_coupe: false,
    sale_on_two: false,
    type_abbr: '2??',
    type_abbr_int: '',
    is_el_reg_possible: true,
    uz: false,
    sel_bedding: true
  }.to_json.to_s
end

# hardcoded cookies, do not read it plz
def parse_cookie(response)
  response['set-cookie'].split('; ').map do |cookie|
    cookie = cookie.split(', ')[1] if cookie.include?("path")
    next if cookie == nil

    cookie_arr = cookie.split("=")
    "#{cookie_arr[0]}=#{cookie_arr[1]}"
  end.compact[0..4].join('; ') + "; session=#{$session}"
end
