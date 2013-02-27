class MobileController < ApplicationController

	def index
		render :layout=>"mobile"
	end

	def flyers
		pageSize = 25
		if params[:per]
			pageSize = params[:per].to_i
		end
		_page = 1
		if params[:page]
			_page = params[:page].to_i
		end
		
		_version = "1.0"
		if params[:ver]
			_version = params[:ver]
		end
		
		Gabba::Gabba.new("UA-31288505-1", "http://www.flyerzero.com").page_view("Mobile", "mobile/flyers")
		if params[:lat] != nil && params[:lat] != ''
			ll = Geokit::LatLng.new(params[:lat], params[:lng])
		end

		
		@count = Event.by_ll_and_radius_three_ranges(ll, 5, 25, 60)
		@now = @count.page(_page).per(pageSize)

		

		hashtags=[]
		for f in @now
			f.distance_from_object = ll
			hashtags += f.tag_list if f.tag_list.count > 0
		end
		
		hashtags = hashtags.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }.to_a.sort{|a, b| a[1] <=> b[1]}
		
		if _version != "1.0"
			responseArray = { :events => JSON.parse(@now.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :get_distance_from])),
				:hashtags=>hashtags,
				:total_pages=> (@count.size / pageSize.to_f).ceil, 
				:current_page => _page, 
				:per_page=>pageSize,
				:api_version=>_version}
		else
			responseArray = JSON.parse(@now.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :get_distance_from]))
		end
		
		render :json=>responseArray
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
