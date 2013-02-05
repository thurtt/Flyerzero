class Venue < ActiveRecord::Base
	validates :name, :lat, :lng, :presence => true

	def add_venue_if_necessary(venue, type)
		# check to see if the venue already exists
		venueItem = Venue.find_by_facebook_id_or_foursquare_id(venue["id"], venue["id"])

		if venueItem == nil
			venueName = venue["name"]
			point = {}
			if type == "facebook"
				point = { :lat=>venue["lat"].to_f, :lng=>venue["lng"].to_f }
			end
			if type == "foursquare"
				point = { :lat=>venue["location"]["lat"].to_f, :lng=>venue["location"]["lng"].to_f }
			end
			
			# if it doesn't exist, check to see if maybe there is another
			# venue that was added by another service

			# get all nearby venues
			area = min_max_coordinates(point, .003)
			closeVenues = where('lat > ? && lat < ? && lng > ? && lng < ?', area[:lat_min], area[:lat_max], area[:lng_min], area[:lng_max])

			# do some sort of name match
			matcher = FuzzyMatch.new(closeVenues.all, :read=>:name)

			# if there is, just add the appropriate venue_id
			matchedVenue = matcher.find(venueName)

			if matchedVenue				
				if type == "facebook"
					matchedVenue.facebook_id = venue.facebook_id
				end
				if type == "foursquare"
					matchedVenue.foursquare_id = venue.foursquare_id
				end
				matchedVenue.save!
			else
				# if there isn't add the venue to our database
				if type == "facebook"
					add_facebook_venue(venue)
				end

				if type == "foursquare"
					add_foursqaure_venue(venue)
				end
			end
		end
	end

	def add_foursqaure_venue(foursquareVenue)
		# if there is no venue in our db, copy the one from foursquare
		venue = Venue.new
		venue.name = foursquareVenue["name"]
		venue.lat = foursquareVenue["location"]["lat"]
		venue.lng = foursquareVenue["location"]["lng"]
		venue.foursquare_id = foursquareVenue["id"]
		venue.address = foursquareVenue["location"]["address"]
		venue.city = foursquareVenue["location"]["city"]
		venue.state = foursquareVenue["location"]["state"]
		venue.zip = foursquareVenue["location"]["postalCode"]
		venue.country = foursquareVenue["location"]["country"]
		venue.save!
	end

	def add_facebook_venue(facebookVenue)
		venue = Venue.new
		venue.name = facebookVenue["name"]
		venue.lat = facebookVenue["lat"]
		venue.lng = facebookVenue["lng"]
		venue.facebook_id = facebookVenue["id"]
		venue.save!
	end
end
