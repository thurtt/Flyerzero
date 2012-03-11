class BoardController < ApplicationController

	def index
		@flyers = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page]).per(10)
		@event = Event.new()
	end
	
	def authenticate
		flyer = Event.find_by_verification_hash(params[:v]) if params[:v] 
		session[:email] = flyer.email if flyer != nil
		redirect_to :action=>"index"
	end
	
end
