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
			
	def isrecent?
		return true if expiry < DateTime.now.beginning_of_day + 2.day
		return false
	end
end
