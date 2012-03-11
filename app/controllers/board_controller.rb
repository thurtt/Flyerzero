class BoardController < ApplicationController

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

end
