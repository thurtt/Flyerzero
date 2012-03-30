class ApplicationController < ActionController::Base
	geocode_ip_address
	protect_from_forgery

end
