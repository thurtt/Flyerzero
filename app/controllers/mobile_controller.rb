class MobileController < ApplicationController
	
	def index
		@now = Event.within(5, :origin => @orgin).page(params[:page]).per(6)
		@soon = Event.within(5, :origin => @orgin).page(params[:page]).per(6)
	end
	
end
