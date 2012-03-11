class ApplicationController < ActionController::Base
	geocode_ip_address
	protect_from_forgery
	before_filter :findme
	
	def findme
		
		if params[:lat] != nil && params[:lat] != ''
			@origin = [params[:lat], params[:lng]]
			res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode @origin
			session[:origin] = res.full_address
		end
		
		if session[:origin] 
			@origin = Geokit::Geocoders::MultiGeocoder.geocode(session[:origin])
		else
			#@origin = Geokit::Geocoders::IpGeocoder.geocode(request.remote_ip)
			@origin = Geokit::Geocoders::MultiGeocoder.geocode('1119 Page st, Charlottesville, VA')
			#@origin = '1119 Page st, Charlottesville, VA'
		end
	end
end
