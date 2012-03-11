class MobileController < ApplicationController
	
	def index
		@now = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page]).per(6)
		@soon = Event.within(5, :origin => @orgin).where('validated > 0').page(params[:page]).per(6)
	end
	
end
