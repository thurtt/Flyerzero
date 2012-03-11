class MobileController < ApplicationController
	
	def index
	end
	
	def flyers
		
		@now = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page]).per(6)
		@soon = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page]).per(6)
		
		render :partial=>"flyers"
	end
end
