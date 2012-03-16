class BoardController < ApplicationController
	skip_before_filter :findme, :only=>[:callback ]

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
		@flyers = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page]).per(10)
		render :partial=>"flyers"
	end
	
	def venue
		client = Foursquare2::Client.new(:client_id => 'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G', :client_secret => 'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H')
		#@venues = client.search_venues(:ll => @origin.ll, :query => 'Starbucks')
		@venues = client.explore_venues(:ll => @origin.ll, :radius => '500')
		render :text=>@venues.inspect
	end
	
	def callback
		render :text=>"success"
	end

end
