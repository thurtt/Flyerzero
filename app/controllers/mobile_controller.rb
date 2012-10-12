class MobileController < ApplicationController

	def index
		render :layout=>"mobile"
	end

	def flyers
		pageSize = 25
		if params[:per]
			pageSize = params[:per]
		end
		
		Gabba::Gabba.new("UA-31288505-1", "http://www.flyerzero.com").page_view("Mobile", "mobile/flyers")
		if params[:lat] != nil && params[:lat] != ''
			ll = Geokit::LatLng.new(params[:lat], params[:lng])
		end


		@now = Event.within(5, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page]).per(pageSize)
		if @now.length < 20
			@now = Event.within(25, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page]).per(pageSize)
		end
		if @now.length < 20
			@now = Event.within(60, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page]).per(pageSize)
		end
		if @now.length < 1
			@now = Event.where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry').page(params[:page])
		end

		for f in @now
			f.distance_from_object = ll
		end

		render :json=>@now.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :get_distance_from])
	end

	def flyer
		Gabba::Gabba.new("UA-31288505-1", "http://www.flyerzero.com").page_view("Mobile", "mobile/flyer")
		if params[:id]
			@flyer = Event.find(params[:id]) if Event.exists?(params[:id])
			render :json=>@flyer.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info])
		end
	end

	def found

	end

	def found_user
		Gabba::Gabba.new("UA-31288505-1", "http://www.flyerzero.com").page_view("Mobile", "mobile/found_user")
		result = { :status=>"Error updating Achievement", :points=>0, :currency=>0 }
	  	if params[:email] && params[:email] != "undefined" && params[:event_id] && params[:foursquare_id]
			achieve = Achievement.find_by_email(params[:email])
			hash = Digest::SHA1.hexdigest("#{params[:email]}#{params[:event_id]}#{params[:foursquare_id]}")
			hashRecord = Unique.find_by_hash( hash )

			if !hashRecord
			      # add our hash to the uniques table
			      uniqueHash = Unique.new(:hash=>hash)
			      uniqueHash.save

			      # add the user or just update their cool points
			      if !achieve
				    achieve = Achievement.new( { :email=>params[:email], :points=>0, :currency=>0 } )
			      end
			      achieve.complete
			      achieve.save
			      result[:status] = "success"
			else
			     result[:status] = "Duplicate user search result. Nice try."
			end

			if achieve
			      result[:points] = achieve.points
			      result[:currency] = achieve.currency
			end
	  	else
		      result[:status] = "Bad input parameters"
	  	end
	  	render :json=>result.to_json
	end
end
