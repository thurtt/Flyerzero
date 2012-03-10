class BoardController < ApplicationController

	def index
		#@origin = '1119 Page St, Charlottesville, VA'
		@flyers = Event.within(5, :origin => @orgin)
	end
	
end
