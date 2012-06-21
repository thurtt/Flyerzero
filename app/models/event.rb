class Event < ActiveRecord::Base
	belongs_to :event
	
	acts_as_mappable
	validates_presence_of :email
	validates_presence_of :expiry
	validates_presence_of :validation_hash
	has_attached_file :photo, :styles => {
			:thumb=> "130x163#",
			:small  => "130x163>",
			:medium => "400x500>",
			:large =>   "600x750>" }
			
	attr_accessor :distance_from_object
			
	def get_distance_from(point = nil)
		point ||= distance_from_object
		return distance_from(point)
	end
	
	def isrecent?
		return true if expiry < DateTime.now.beginning_of_day + 2.day
		return false
	end
	
	def map_photo
		photo.url(:small)
	end
	
	def map_photo_info
		photo.url(:medium)
	end
end
