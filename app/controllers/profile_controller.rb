class ProfileController < ApplicationController
	def view
		@profile = Achievement.find(params[:id])
		@flyers = Event.where(:email=>@profile.email).order('expiry desc')
		
		
	end
end
