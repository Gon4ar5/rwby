class User
  attr_accessor :lang, :logged_fname, :logged_lname, :logged_email, :guid, :logged_token, :session, :logged_time,
  				:login, :password, :dologin, :car_type
  
  def initialize
    @lang = "a99e6f9df71a6809253b6a85825dec8e3130af73%7Een"
    @login = "eblo-tupoe1488@mail.ru"
    @password = "qweqweqwe11"
    @dologin = "Login"
    @car_type = 4
  end
end