class User
  attr_accessor :login, :password, :dologin
  
  def initialize(login = nil, password = nil)
    @login = login || "eblo-tupoe1488@mail.ru"
    @password = password || "qweqweqwe11"
    @dologin = "Login"
  end
end