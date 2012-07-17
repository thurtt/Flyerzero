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

	scope :current_and_valid_by_ll_and_radius, lambda do |ll, radius|
	  within(radius, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry')
	end

	scope :valid_by_promoter, lambda do |promoter_hash|
	    result = Achievement.find_by_gravatar_hash(promoter_hash)
	    where(:email=>result.email).where('validated > 0').order('expiry')
	end

	scope :current_and_valid_by_promoter, lambda do |promoter_hash|
	    valid_by_promoter(promoter_hash).where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry')
	end

	scope :current_and_valid_by_venue, lambda do |venue_id|
	    where(:venue_id=>venue_id).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day])
	end

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
