class ApplicationController < ActionController::Base
	geocode_ip_address
	protect_from_forgery
	before_filter :findme
	
	def findme
		if session[:origin] 
			@origin = session[:origin] 
		else
			@origin = Geokit::Geocoders::IpGeocoder.geocode(request.remote_ip)
		end
	end
end
