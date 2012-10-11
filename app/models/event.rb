class Event < ActiveRecord::Base
	include ApplicationHelper
	
	belongs_to :event
	acts_as_mappable
	validates_presence_of :email
	validates_presence_of :expiry
	validates_presence_of :validation_hash
	has_attached_file :photo, :styles => {
			:thumb=> "100x",
			:small  => "200x",
			:cropped =>"",
			:medium => "400x",
			:large =>   "600x" },
		:convert_options => { 
			:cropped => "-gravity north -thumbnail 200x200^ -extent 200x200"}

	attr_accessor :distance_from_object

	scope :is_current, lambda {where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry')}
	scope :is_valid, lambda {where('validated > 0').order('expiry')}
	scope :in_range, lambda {|start, stop| where(['expiry >= ? && expiry <= ?', start, stop]).order('expiry')}
	scope :by_ll_and_radius, lambda {|ll, radius| within(radius, :origin => ll).order('expiry')}
	scope :by_promoter, lambda {|promoter_hash|
		    result = Achievement.find_by_gravatar_hash(promoter_hash)
		    where(:email=>result.email).order('expiry') }
	scope :by_venue, lambda{|venue_id| where(:venue_id=>venue_id).order('expiry')}

	def get_distance_from(point = nil)
		point ||= distance_from_object
		return distance_from(point)
	end

	def isrecent?
		return true if expiry < DateTime.now.beginning_of_day + 2.day
		return false
	end
	
	
	def map_photo
		photo.url(:cropped)
	end

	def map_photo_info
		photo.url(:medium)
	end
	
	def gravatar
		gravatar_url(email)
	end
	
	def promoter
		Achievement.find_by_email(email).id
	end
	
end
