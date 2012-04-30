class MobileController < ApplicationController
	
	def index
		render :layout=>"mobile"
	end
	
	def flyers
		

		if params[:id]
			@flyer = Event.find(params[:id]) if Event.exists?(params[:id])
		end
		
		if params[:lat] != nil && params[:lat] != ''
			ll = Geokit::LatLng.new(params[:lat], params[:lng])
		end
			
		
		@now = Event.within(5, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page])
		if @now.length < 20
			@now = Event.within(25, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page])
		end
		
		render :json=>@now.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info])
	end
end
