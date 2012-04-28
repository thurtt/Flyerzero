class BoardController < ApplicationController
	#skip_before_filter :findme, :only=>[:callback, :venue, :change_location]
	before_filter :findme, :only=>[:index]
	before_filter :updateme, :only=>[:flyers]

	def findme

		if session[:origin]
			@origin = Geokit::Geocoders::MultiGeocoder.geocode(session[:origin])
			#@origin is now a Geoloc object.
		else
			@origin = Geokit::Geocoders::IpGeocoder.geocode(request.remote_ip)
			#@origin is now a Geoloc object.

			#@origin = Geokit::Geocoders::MultiGeocoder.geocode('YOUR ADDRESS HERE')
			res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode @origin
			session[:origin] = res.full_address
		end

		session[:ll] = @origin.ll
		return true
	end


	def updateme
		if params[:lat] != nil && params[:lat] != ''
			res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode [params[:lat], params[:lng]]
			session[:origin] = res.full_address


			#@origin = Geokit::Geocoders::MultiGeocoder.geocode(session[:origin])
			@origin = Geokit::LatLng.new(params[:lat], params[:lng])

			session[:ll] = @origin.ll
			return true

		end
	end



	def index

	end

	def authenticate
		flyer = Event.find_by_verification_hash(params[:v]) if params[:v]
		session[:email] = flyer.email if flyer != nil
		redirect_to :action=>"index"
	end

	def flyers
		if params[:id]
			@flyer = Event.find(params[:id]) if Event.exists?(params[:id])
			# set our location to the location of the flyer
			# this makes it so everyone can see it
			if @flyer
			    res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode [@flyer.lat, @flyer.lng]
			    session[:origin] = res.full_address
			    @origin = Geokit::LatLng.new(@flyer.lat, @flyer.lng)
			    session[:ll] = @origin.ll
			end
		end

		if params[:validation] and params[:event_id]
			@event = Event.find_by_id_and_validation_hash( params[:event_id], params[:validation] )
			@event = Event.new() if not @event
		else
			@event = Event.new()
		end

		@now = Event.within(5, :origin => session[:ll]).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page])
		if @now.length < 20
			@now = Event.within(25, :origin => session[:ll]).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page])
		end

		render :partial=>"flyers"
	end

	def venue
		if params[:term].length < 2
		      render :json=>[] and return
		end

		# foursquare autocomplete endpoint
		endpoint = 'https://api.foursquare.com/v2/venues/suggestcompletion'
		response = RestClient.get endpoint, {:params=>{ :ll=>session[:ll],
						      :v=>'20120411',
						      :query=>params[:term],
						      :limit=>15,
						      :client_id=>'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G',
						      :client_secret=>'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H'}
						    }
		venues = (ActiveSupport::JSON.decode(response))["response"]["minivenues"]
		venues.map!{ |venue| { :name=>venue["name"],
				       :cross_street=>venue["location"]["crossStreet"],
				       :address=>venue["location"]["address"],
				       :lat=>venue["location"]["lat"],
				       :lng=>venue["location"]["lng"],
				       :venue_id=>venue["id"],
				       :icon=> proc do
						if venue["category"]
						      icon = venue["category"]["icon"]["prefix"] + venue["category"]["icon"]["sizes"][0].to_s + venue["category"]["icon"]["name"]
						else
						      icon = nil
						end
				       end.call
				     }
			   }
		render :json=> venues
	end

	def change_location
		#todo here -- get address from submission
		# geoloc to get long/lat,
		# give it back to the user to insert into the original process
		# loadFlyer()
		@origin = Geokit::Geocoders::MultiGeocoder.geocode(params[:location])
		render :partial=>"address_responder"
	end

	def callback
		render :text=>"success"
	end

	def about
		redirect_to :action=>"index", :id=>"about"
	end

end
