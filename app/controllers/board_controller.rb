class BoardController < ApplicationController
	skip_before_filter :findme, :only=>[:callback, :venue]

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
		@event = Event.new()
		@now = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page])
		@soon = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page])
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
				       :id=>venue["id"],
				       :icon=>venue["category"] ? venue["category"]["icon"] : nil
				     }
			   }
		render :json=> venues
	end


	def callback
		render :text=>"success"
	end

end
