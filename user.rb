class User
  attr_accessor :lang, :logged_fname, :logged_lname, :logged_email, :guid, :logged_token, :session, :logged_time,
  				:login, :password, :dologin, :car_type, :order_basket_id
  
  def initialize
    @login = "eblo-tupoe1488@mail.ru"
    @password = "qweqweqwe11"
    @dologin = "Login"
    @car_type = 4
  end
end