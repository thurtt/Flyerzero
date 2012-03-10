class BoardController < ApplicationController

	def index
		@flyers = Event.within(5, :origin => @orgin).page(params[:page]).per(10)
	end
	
end
