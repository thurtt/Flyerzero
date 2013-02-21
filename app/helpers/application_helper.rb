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
		venue_info = {}
		if not event or not event.venue_id
			venue_info = {
				:name=>"",
				:location=>"No Venue Chosen",
				:lat=>"",
				:lng=>"",
			}
		else
			venue_id = event.venue_id
			type, id = venue_id.split(':')
			
			# For backwards compatibility
			if type == venue_id  && id.blank?
				id = type
				type = 'fs'
			end

			if type == 'fs'
				fs_venue = Venue.reverse_venue_lookup( id )
				if fs_venue
					venue_info = {
						:name=>fs_venue["name"],
						:lat=>fs_venue["location"]["lat"],
						:lng=>fs_venue["location"]["lng"],
						:venue_id=>fs_venue["id"],
					}
					# address if applicable
					venue_info[:location] = fs_venue["location"].has_key?("address") ? fs_venue["location"]["address"] : ""

					# add cross street if necessary
					if ( fs_venue["location"].has_key?("crossStreet") && options[:xstreet] != false)
						venue_info[:location] += " (#{fs_venue["location"]["crossStreet"]})"
					end
				else
					venue_info = {
						:name=>"",
						:location=>"",
						:lat=>event.lat,
						:lng=>event.lng,
						:venue_id=>event.venue_id,
					}
				end
			end

			if type == 'lv'
				lv_venue = Venue.find(id)
				venue_info = {
					:name=>lv_venue.name,
					:lat=>lv_venue.lat,
					:lng=>lv_venue.lng,
					:venue_id=>venue.id
				}
			end
		end
		render :partial=>"board/venue", :locals=>{ :venue=>venue_info }
	end

	def foursquare_venue_name( venue_id )
		type, id = venue_id.split(':')

		# backwards compatibility
		if type == venue_id  && id.blank?
			id = type
			type = 'fs'
		end

		if type == 'fs'
			venue_info = Venue.reverse_venue_lookup( id )
			if venue_info
				return venue_info["name"]
			end
		end
		if type == 'lv'
			venue_info = Venue.find(id)
			return venue_info.name
		end
		return ''
	end

	def min_max_coordinates(point, distance)
		# min and max longitude are easy peasy
		lat_min = point[:lat] - distance
		lat_max = point[:lat] + distance
		lng_min = point[:lng] - Math.asin(Math.sin(distance)/Math.cos(point[:lat]))
		lng_max = point[:lng] + Math.asin(Math.sin(distance)/Math.cos(point[:lat]))

		return {:lat_min=>lat_min, :lat_max=>lat_max, :lng_min=>lng_max, :lng_max=>lng_min}
	end

	def linkify_hashtags(text = "", event_id, outerClass, innerClass)
		result = "<span href=\"/item/?event_id=#{event_id}\" class=\"#{outerClass} title_link\">#{text}</span>"
		text.scan(/\s(#[a-zA-Z0-9_]+)/) { |tags|
			tags.each { |tag|
				result = result.sub(tag, "<span tag=\"#{tag}\" class=\"#{innerClass} hashtag\">#{tag}</span>")
			}
		}
		return result.html_safe
	end
end
