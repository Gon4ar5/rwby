STATION = {
  minsk: '2100001',
  pinsk: '2100180'
}

# set guid, logged_token, session, logged_time, lang headers to global variables
def set_headers_from_response(response, user)
  response['set-cookie'].split('; ').map do |cookie|
    cookie = cookie.split(', ')[1] if cookie.include?("path")
    next if cookie == nil

    cookie_arr = cookie.split("=")

    case cookie_arr[0]
      when 'logged_token'
        user.logged_token ||= cookie_arr[-1] if cookie_arr[-1] != 'deleted'
      when 'logged_fname'
        ser.logged_fname ||= cookie_arr[-1]
      when 'logged_lname'
        user.logged_lname ||= cookie_arr[-1]
      when 'logged_email'
        user.logged_email ||= cookie_arr[-1]
      when 'logged_time'
        user.logged_time = cookie_arr[-1]
      when 'session'
        user.session ||= cookie_arr[-1]
      when 'lang'
        user.lang ||= cookie_arr[-1]
      when 'guid'
        user.guid ||= cookie_arr[-1]
    end
  end
end

# sets and returns cookies for each request
def set_request_cookie_header(request, user, guid_required: false)
  #Cookie: session=reflvt254mqfq9l95hcrrjiqn2; __utmc=168334370; __utmz=168334370.1679319889.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _ga=GA1.3.1113300649.1679319889; _gid=GA1.3.1640040900.1679512248; __utma=168334370.1113300649.1679319889.1679512248.1679523896.5; 
  #guid=976af349ae70c6584c9f0bc7a5cefbd0d5f79863%7Edd8c972e7eb7a4eaaf489f6c619765fe; 
  #logged_fname=184e41af1cc8fbe6a2c2d5a8af974116a4bbe033%7Etupoe; logged_lname=72d6b8271554ac80005cd6702fa762aa9418ab14%7Eeblo; logged_email=c661b81441ff41aac52a84d6ee0b5e8c0c52d7f3%7Eeblo-tupoe1488%40mail.ru; logged_token=80a3ca639d31e9ef91511844403b8a7613f2a41d%7EeyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwidXNlciI6eyJpZCI6MTQ5MjYxOSwiZW1haWwiOiJlYmxvLXR1cG9lMTQ4OEBtYWlsLnJ1IiwibGFuZ3VhZ2UiOiJlbiJ9LCJhdXRoIjpbeyJhdXRob3JpdHkiOiJST0xFX1UifV0sImlhdCI6MTY3OTUyNDM5NSwiZXhwIjoxNjgwMzg4Mzk1fQ.h8dpxg1HBkbgBicHfbVSMV1AtOc2FrtWdQR9dNHuA8CO7x-y71S6Vz2MKoz7DF2V_XT5rMx6B3VQYEufWBKuVxkUuwIPEXfqO3CckUe5j-vNUKmXoduebRhNgAR4Ks4_QBaCe6x175Jg561yYv5msV65qK2nz5_hGl8DxS3wICUYscbvKr3jX9CmCxmwo8jFsSAOT8tBQNbmJ_pr9AQP5xRKpKpGWl2ksVEREbzf2v2deNZUYD81QG-ZPQxu-5rsEGV5maedQ0C_gGhVosb0yI6tGXuPF0zzF0dPbgDIKBf3ySuq_2xHjkzXoiuBXay3aiKOSpj1PNaahRekt2SvYg; __utmt=1; _gat_UA-151514847-1=1; lang=34c3fd6e2166eb010467309a0411bcbd1bad6ac7%7Een; logged_time=c21c1bc8d5657acbf92240199505a909a96de89f%7E1679524837; __utmb=168334370.20.10.1679523896
  request["Cookie"] = "lang=#{user.lang};"
  request["Cookie"] += " logged_fname=#{user.logged_fname};" if user.logged_fname
  request["Cookie"] += " logged_lname=#{user.logged_lname};" if user.logged_lname
  request["Cookie"] += " logged_email=#{user.logged_email};" if user.logged_email
  request["Cookie"] += " logged_token=#{user.logged_token};" if user.logged_token
  request["Cookie"] += " logged_time=#{user.logged_time};" if user.logged_time
  request["Cookie"] += " session=#{user.session};" if user.session

  request["Cookie"] += request["Cookie"] + " guid=#{user.guid};" if guid_required

  request["Cookie"]
end

# Add common headers and return request object
def add_default_headers(request, user, add_addtl_headers: nil)
  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
  request["Accept-Language"] = "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7"
  request["Cache-Control"] = "max-age=0"
  request["Connection"] = "keep-alive"
  request["Cookie"] = "session=#{user.session}; lang=#{user.lang};" 
  request["Sec-Fetch-Dest"] = "document"
  request["Sec-Fetch-Mode"] = "navigate"
  request["Sec-Fetch-Site"] = "cross-site"
  request["Sec-Fetch-User"] = "?1"
  request["Upgrade-Insecure-Requests"] = "1"
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
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
    depStationCode: STATION["minsk"],
    departureDate: Date.today.to_s,
    departureTime: "22:49",
    orientation: "H",
    train: "657Б",
    width: 960
  }.to_json.to_s
end

def set_passanger_data(request)
  request.set_form_data(
    'agreement' => 2,
    'last_name_1': 'IVANOB',
    'first_name_1': 'IVAN',
    'middle_name_1': 'IVANOVICH',
    'document_type_1': 'ПБ',
    'document_number_1': 'МР1234567',
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
    car_type: 13,
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

# hardcoded cookies, do not read it plz
def parse_cookie(response, user)
  response['set-cookie'].split('; ').map do |cookie|
    cookie = cookie.split(', ')[1] if cookie.include?("path")
    next if cookie == nil

    cookie_arr = cookie.split("=")
    "#{cookie_arr[0]}=#{cookie_arr[1]}"
  end.compact[0..4].join('; ') + "; session=#{user.session}"
end
