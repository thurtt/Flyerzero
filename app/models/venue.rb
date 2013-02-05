class Venue < ActiveRecord::Base
	validates :name, :lat, :lng, :presence => true
	scope :by_facebook_id_or_foursquare_id, lambda{|facebook_id, foursquare_id| where(['facebook_id = ? || foursquare_id <= ?', facebook_id, foursquare_id])}

	def self.add_venue_if_necessary(venueData)
		# check to see if the venue already exists
		venueItem = Venue.by_facebook_id_or_foursquare_id(venueData[:venue_id], venueData[:venue_id])
		if venueItem.blank?
			point = { :lat=>venueData[:lat].to_f, :lng=>venueData[:lng].to_f }

			# get all nearby venues
			area = min_max_coordinates(point, 0.003)
			closeVenues = where('lat > ? && lat < ? && lng > ? && lng < ?', area[:lat_min], area[:lat_max], area[:lng_min], area[:lng_max])

			# do some sort of name match
			matcher = FuzzyMatch.new(closeVenues.all, :read=>:name)

			# if there is, just add the appropriate venue_id
			matchedVenue = matcher.find(venueData[:name])
			if matchedVenue	
				matchedVenue.update_attributes(venueData)			
				matchedVenue.save!
			else
				# if there isn't add the venue to our database
				venue = Venue.new(venueData)
				venue.save!
			end
		end
	end
end
