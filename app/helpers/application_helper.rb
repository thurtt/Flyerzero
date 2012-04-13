module ApplicationHelper
	def gravatar_url( address, opts = {} )
		s = opts[:size] == nil ? '50' : opts[:size]
		r = opts[:rating] == nil ? 'pg' : opts[:rating]
		d = opts[:default] == nil ? 'mm' : opts[:default]
		return "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(address)}?s=#{s}&r=#{r}&d=#{d}"
	end

	def gravatar_hash( address )
		return Digest::MD5.hexdigest(address)
	end

	def foursquare_venue( venue_id )
		venue_info = {}
		if not venue_id
		      venue_info = {
			  :name=>"",
			  :location=>"No Venue Chosen",
			  :lat=>"",
			  :lng=>"",
			  :icon=>"",
		      }
		else
		      venue = reverse_venue_lookup( venue_id )
		      venue_info = {
				      :name=>venue["name"],
				      :location=>venue["location"]["address"] ,
				      :lat=>venue["location"]["lat"],
				      :lng=>venue["location"]["lng"],
				      :icon=> proc do
					      if venue["categories"]
						    icon_info = venue["categories"][0]["icon"]
						    icon = icon_info["prefix"] + icon_info["sizes"][0].to_s + icon_info["name"]
					      else
						    icon = nil
					      end
				      end.call
				    }
		      # add cross street if necessary
		      if ( venue["location"]["crossStreet"] )
			    venue_info[:location] += " (#{venue["location"]["crossStreet"]})"
		      end
		end
		render :partial=>"venue", :locals=>{ :venue=>venue_info }
	end
end

def foursquare_venue_name( venue_id )
	venue_info = reverse_venue_lookup( venue_id )
	return venue_info["name"]
end

def reverse_venue_lookup( venue_id )
	endpoint = 'https://api.foursquare.com/v2/venues/' + venue_id
	response = RestClient.get endpoint, {:params=>{
					      :v=>'20120411',
					      :client_id=>'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G',
					      :client_secret=>'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H'}
					    }
	venue = ActiveSupport::JSON.decode(response)["response"]["venue"]
end
