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
			@origin = Geokit::Geocoders::IpGeocoder.geocode(request.remote_ip)
			res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode @origin
			session[:origin] = res.full_address
			
			#@origin = Geokit::Geocoders::MultiGeocoder.geocode('YOUR ADDRESS HERE')
		end
	end
end
