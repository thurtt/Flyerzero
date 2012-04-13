class ProfileController < ApplicationController
	def view
		@profile = Achievement.find(params[:id])
		@flyers = Event.where(:email=>@profile.email, :validated=>1).order('expiry desc')
		
		
	end
end
