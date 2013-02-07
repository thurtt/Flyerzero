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

	def foursquare_venue( event, options = {} )
		if not event or not event.venue_id
		      venue_info = {
			  :name=>"",
			  :location=>"No Venue Chosen",
			  :lat=>"",
			  :lng=>"",
			  :icon=>"",
		      }
		else
		      venue_id = event.venue_id
		      venue_info = {}
		      venue = reverse_venue_lookup( venue_id )
		      if venue
			      venue_info = {
					      :name=>venue["name"],
					      :lat=>venue["location"]["lat"],
					      :lng=>venue["location"]["lng"],
					      :venue_id=>venue["id"],
					      :icon=> proc do
						      if venue["categories"].length > 0
							    icon_info = venue["categories"][0]["icon"]
							    icon = icon_info["prefix"] + icon_info["sizes"][2].to_s + icon_info["name"]
						      else
							    icon = nil
						      end
					      end.call
					    }
			      # address if applicable
			      venue_info[:location] = venue["location"].has_key?("address") ? venue["location"]["address"] : ""

			      # add cross street if necessary
			      if ( venue["location"].has_key?("crossStreet") && options[:xstreet] != false)
				    venue_info[:location] += " (#{venue["location"]["crossStreet"]})"
			      end
		      else
			      venue_info = {
				  :name=>"",
				  :location=>"Error retrieving venue name.",
				  :lat=>event.lat,
				  :lng=>event.lng,
				  :venue_id=>event.venue_id,
				  :icon=>""
			    }
		      end
		end
		render :partial=>"board/venue", :locals=>{ :venue=>venue_info }
	end
end

def foursquare_venue_name( venue_id )
	venue_info = reverse_venue_lookup( venue_id )
	if venue_info
	  return venue_info["name"]
	end
	return ''
end

def reverse_venue_lookup( venue_id )
	endpoint = 'https://api.foursquare.com/v2/venues/' + venue_id
	response = RestClient.get endpoint, {:params=>{
					      :v=>'20120411',
					      :client_id=>'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G',
					      :client_secret=>'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H'}
					    }
	if response.code != 200
	  venue = nil
	else
	  venue = ActiveSupport::JSON.decode(response)["response"]["venue"]
	end
    return venue
end

def min_max_coordinates(point, distance)
	# min and max longitude are easy peasy
	lat_min = point[:lat] - distance
	lat_max = point[:lat] + distance
	lng_min = point[:lng] - Math.asin(Math.sin(distance)/Math.cos(point[:lat]))
	lng_max = point[:lng] + Math.asin(Math.sin(distance)/Math.cos(point[:lat]))

	return {:lat_min=>lat_min, :lat_max=>lat_max, :lng_min=>lng_max, :lng_max=>lng_min}
end

def linkify_hashtags(text, event_id, outerClass, innerClass)
	result = "<span href=\"/item/?event_id=#{event_id}\" class=\"#{outerClass}\">#{text}</span>"  
	text.scan(/\s(#[a-zA-Z0-9_]+)/) { |tags| 
		tags.each { |tag| 
			result = result.sub(tag, "<span tag=\"#{tag}\" class=\"#{innerClass} hashtag\">#{tag}</span>")
		}
	}
	return result.html_safe
end
