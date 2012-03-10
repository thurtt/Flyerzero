class MobileController < ApplicationController
	
	def index
		@now = Event.within(5, :origin => @orgin)
		@soon = Event.within(5, :origin => @orgin)
	end
	
end
