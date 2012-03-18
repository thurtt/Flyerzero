class BoardController < ApplicationController
	skip_before_filter :findme, :only=>[:callback]

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
		# foursquare autocomplete endpoint
		endpoint = 'https://api.foursquare.com/v2/venues/suggestcompletion'
		response = RestClient.get endpoint, {:params=>{ :ll=>@origin.ll,
						      :query=>params[:term],
						      :limit=>15,
						      :client_id=>'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G',
						      :client_secret=>'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H'}
						    }
		venues = (ActiveSupport::JSON.decode(response))["response"]["minivenues"]
		venues.map!{ |venue| { :name=>venue["name"],
				       :cross_street=>venue["location"]["crossStreet"],
				       :address=>venue[]
				     }
			   }

	end
	#def venue
	#	# ruby 1.9.x on mac needs to know where the certs are
	#	client = Foursquare2::Client.new(:client_id => 'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G',
	#					 :client_secret => 'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H',
	#					 :ssl => { :verify => OpenSSL::SSL::VERIFY_PEER, :ca_file => '/opt/local/share/curl/curl-ca-bundle.crt' }
	#					 )
	#	@venues = client.search_venues(:ll => @origin.ll, :query => params[:term])
	#	venue_list = @venues.groups[0].items
	#	venue_list.map!{ |venue| { :name=>venue.name,
	#					    :address=>venue.location.address,
	#					    :cross_street=>venue.location.crossStreet,
	#					    :lat=>venue.location.lat,
	#					    :lng=>venue.location.lng,
	#					    :venue_id=>venue.id } }
	#	render :json=> venue_list
	#end

	def callback
		render :text=>"success"
	end

end
