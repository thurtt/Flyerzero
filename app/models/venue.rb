class Venue < ActiveRecord::Base
	validates :lat, :lng, :presence => true
	acts_as_mappable

	def self.reverse_venue_lookup( venue_id )
		endpoint = 'https://api.foursquare.com/v2/venues/' + venue_id
		response = RestClient.get endpoint, {:params=>{
											 :v=>'20120411',
											 :client_id=>'PD1MFQUHYFZKOWIND0L3AU3HEZ2FHUP1MVJ2BZG0NZXRJ14G',
											 :client_secret=>'UUSATLQWYXAGCOICODDAS1YFUPTHNS4FSFYWONA2SA4VRU0H'}																			 }
		if response.code != 200
			venue = nil
		else
			venue = ActiveSupport::JSON.decode(response)["response"]["venue"]
		end
		return venue
	end

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
