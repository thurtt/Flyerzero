class Venue < ActiveRecord::Base
	validates :lat, :lng, :presence => true
	acts_as_mappable

	def self.add_venue_if_necessary(venueId)
		type, id = venueId.split(':')

		if type == 'fs'
			# check to see if the venue already exists
			venueItem = Venue.find_by_foursquare_id(id)			
			if venueItem.blank?
				foursquareVenue = reverse_venue_lookup(id)
				venueData = { :name => foursquareVenue["name"],
							  :foursquare_id => foursquareVenue["id"], 
							  :address => foursquareVenue["location"]["address"],
							  :city => foursquareVenue["location"]["city"],
							  :state => foursquareVenue["location"]["state"],
							  :zip => foursquareVenue["location"]["postalCode"],
							  :country => foursquareVenue["location"]["country"],
							  :lat=> foursquareVenue["location"]["lat"], 
							  :lng=>foursquareVenue["location"]["lng"]}

				venue = Venue.new(venueData)
				venue.save!
			end
		end
	end
end
