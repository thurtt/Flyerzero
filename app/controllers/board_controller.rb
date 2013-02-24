class BoardController < ApplicationController
	#skip_before_filter :findme, :only=>[:callback, :venue, :change_location]
	before_filter :findme, :only=>[:index]
	before_filter :updateme, :only=>[:flyers]

	include ApplicationHelper
	
	def authenticateme
		render :text=>authenticate_token(params[:v])
	end
	
	def deauthenticateme
		render :text=>deauthenticate_token
	end
	
	def findme

		if session[:origin]
			@origin = Geokit::Geocoders::MultiGeocoder.geocode(session[:origin])
			#@origin is now a Geoloc object.
		else
			@origin = Geokit::Geocoders::IpGeocoder.geocode(request.remote_ip)
			#@origin is now a Geoloc object.

			#@origin = Geokit::Geocoders::MultiGeocoder.geocode('YOUR ADDRESS HERE')
			res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode @origin
			set_session_location(res)
		end

		session[:ll] = @origin.ll
		return true
	end


	def set_ll_from_latlng(lat,lng)
		res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode [lat, lng]
			set_session_location(res)

			#@origin = Geokit::Geocoders::MultiGeocoder.geocode(session[:origin])
			@origin = Geokit::LatLng.new(lat, lng)

			session[:ll] = @origin.ll
	end
	
	def updateme
		if params[:lat] != nil && params[:lat] != ''
			
			set_ll_from_latlng(params[:lat],params[:lng])
			
			
			return true

		end
	end

	def index
		if params[:validation] and params[:event_id]
			@event = Event.find_by_id_and_validation_hash( params[:event_id], params[:validation] )
			@event = Event.new() if not @event
		else
			@event = Event.new()
		end
	end



	def flyers
		ll = session[:ll]
		if params[:id]
			@flyer = Event.find(params[:id]) if Event.exists?(params[:id])
			# set our location to the location of the flyer
			# this makes it so everyone can see it
			if @flyer

			    # set our search ll to that of our flyer and get everything nearby
			    @origin = Geokit::LatLng.new(@flyer.lat, @flyer.lng)
			    ll = @origin.ll
			end
		end

		if params[:validation] and params[:event_id]
			@event = Event.find_by_id_and_validation_hash( params[:event_id], params[:validation] )
			@event = Event.new() if not @event
		else
			@event = Event.new()
		end

		@now = Event.by_ll_and_radius_three_ranges(ll, 5, 25, 60)

		if params[:hashtag]
			@filter = params[:hashtag]
			@now = @now.tagged_with(params[:hashtag])
		end
		
		@now = @now.page(params[:page]).per(20)
		
		for f in @now
			f.distance_from_object = session[:ll]
		end

		render :partial=>"flyers"
	end

	def venue
		if params[:term].length < 2
		      render :json=>[] and return
		end
		
		if params[:lat] != nil && params[:lat] != '' && !session[:ll]
			set_ll_from_latlng(params[:lat],params[:lng])
		end
		
		venues = {}
		ourVenues = Venue.search( :name_contains => params[:term] )
		if ourVenues.length == 0
			# foursquare autocomplete endpoint
			endpoint = 'https://api.foursquare.com/v2/venues/suggestcompletion'
			response = RestClient.get endpoint, {:params=>{ :ll=>session[:ll],
							      :v=>'20120411',
							      :query=>params[:term],
							      :limit=>15,
							      :radius=>16093,
							      :client_id=>'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G',
							      :client_secret=>'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H'}
							    }
			venues = (ActiveSupport::JSON.decode(response))["response"]["minivenues"]
			venues.map!{ |venue| { :name=>venue["name"],
					       :cross_street=>venue["location"]["crossStreet"],
					       :address=>venue["location"]["address"],
					       :lat=>venue["location"]["lat"],
					       :lng=>venue["location"]["lng"],
					       :venue_id=>"fs:" + venue["id"],
					     }
				   }
		else
			venues = ourVenues.all.map{ |venue| { :name=>venue["name"],
											  :address=>venue["address"],
											  :lat=>venue["lat"],
											  :lng=>venue["lng"],
											  :venue_id=>"lv:" + venue["id"].to_s
											}
								   }
		end
		respond_to do |format|
		      format.json{render :json=> venues}
		      format.html{render :json=> venues}
		end
	end

	def get_location
		location = Geokit::Geocoders::MultiGeocoder.geocode(params[:location])
		render :json=>location
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

	def set_session_location(res)
		session[:origin] = res.full_address
		session[:city] = res.city
		session[:state] = res.state
		session[:country] = res.country
	end

end
