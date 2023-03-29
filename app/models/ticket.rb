class Ticket
  attr_accessor :seat, :carriage, :carriage_type, :date, :time

  def initialize(seat = nil, carriage = nil, carriage_type = nil, date = nil, time = nil)
  	@seat = seat
  	@carriage = carriage
  	@carriage_type = carriage_type
  	@date = date
  	@time = time
  end
end