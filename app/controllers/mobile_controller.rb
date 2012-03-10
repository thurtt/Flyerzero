class MobileController < ApplicationController
	
	def index
		@now = Event.find(:all)
		@soon = Event.find(:all)
	end
	
end
