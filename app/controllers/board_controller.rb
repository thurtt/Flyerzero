class BoardController < ApplicationController

	def index
		@flyers = Event.all
	end
	
end
