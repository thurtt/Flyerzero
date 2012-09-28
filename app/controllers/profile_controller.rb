class ProfileController < ApplicationController
	def view
		@profile = Achievement.find(params[:id])
		@flyers = Event.where(:email=>@profile.email, :validated=>1).order('expiry desc')
		
		respond_to do |format|
			format.json{render :json=>@flyers.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :gravatar, :promoter]) }
			format.html{render}
		end

	end
	
	def history	
		
		if !params[:email]
			render(:text=>"Invalid Request", :status => 403) and return
		end
			
		@flyers = Event.where(:email=>params[:email], :validated=>1).order('expiry desc')
		
		render :json=>@flyers.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :gravatar, :promoter]) 
	end
	
end
