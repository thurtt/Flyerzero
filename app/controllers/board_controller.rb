class BoardController < ApplicationController

	def index
		@flyers = Event.within(5, :origin => @orgin)
	end
	
end
