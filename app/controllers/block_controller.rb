class BlockController < ApplicationController
  def create
	user = User.new(params[:email], params[:password])
	session = Session.new

	# First unauthorized request to pass.rw.by, just to get session token 
	SenderService.send_request_for_session_token(session)

	# Login post request
	SenderService.send_first_post_request(user, session)

	# Login get https request, return to us logged_time header
	SenderService.send_third_get_request(session)

	# Returns long params string about your route and free_seats(an example can be seen at the end of the method)
	params_for_request = SenderService.get_route_params(session)

	# Returns to us guid after we send the long string from the previous method
	SenderService.send_request_for_guid(params_for_request, session)

	# Returns the train info and emptyPlaces
	free_places_hash = SenderService.send_ajax_req_for_free_places_hash(session)

	# Returns the location of seats in the train by pixels
	train_seats_pixels = SenderService.send_ajax_req_for_train_pixels(free_places_hash, session)

	SenderService.send_request_with_seat_info(free_places_hash, train_seats_pixels, session)

	# Send last request with user info(first-middle-last names, passport data, etc)
	SenderService.send_passanger_info(session)

	# Should check if the ticket has appeared in the backet or not(dont work right now)
	SenderService.send_orders_request(session)


  	render json: {email: user.login}
  end

  def permit_params
    params.permit(:email, :password, :carriage, :seat, :date, :time)
  end
end
