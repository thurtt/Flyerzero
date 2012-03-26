class BoardController < ApplicationController
	skip_before_filter :findme, :only=>[:callback, :venue, :change_location]

	def index

	end

	def authenticate
		flyer = Event.find_by_verification_hash(params[:v]) if params[:v]
		session[:email] = flyer.email if flyer != nil
		redirect_to :action=>"index"
	end

	def set_location
		@origin = Geokit::Geocoders::MultiGeocoder.geocode(params[:location])
		session[:origin] = params[:location] if @origin
		render :text=>'loc set'
	end

	def flyers
		
		if params[:id]
			@flyer = Event.find(params[:id]) if Event.exists?(params[:id])
		end
		
		@event = Event.new()
		
		@now = Event.within(5, :origin => session[:ll]).where('validated > 0').where(['expiry > ? && expiry < ?', Time.now().beginning_of_day - 1.day, Time.now().beginning_of_day + 3.day]).order('expiry').page(params[:page])
		if @now.length < 20
			@now = Event.within(25, :origin => session[:ll]).where('validated > 0').where(['expiry > ? && expiry < ?', Time.now().beginning_of_day - 1.day, Time.now().beginning_of_day + 3.day]).order('expiry').page(params[:page])
		end
		
		
		@soon = Event.within(5, :origin => session[:ll]).where('validated > 0').where(['expiry > ? && expiry < ?', Time.now().beginning_of_day + 2.day, Time.now().beginning_of_day + 1.week]).order('expiry').page(params[:page])
		if @soon.length < 20
			@soon = Event.within(25, :origin => session[:ll]).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day + 2.day]).order('expiry').page(params[:page])
		end
		
		render :partial=>"flyers"
	end

	def venue
		if params[:term].length < 3
		      render :json=>[] and return
		end

		# foursquare autocomplete endpoint
		endpoint = 'https://api.foursquare.com/v2/venues/suggestcompletion'
		response = RestClient.get endpoint, {:params=>{ :ll=>session[:ll],
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
				       :icon=>venue["category"] ? venue["category"]["icon"] : nil
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

end
