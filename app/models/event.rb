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
	
	
	#SOUNDCLOUD CRAP
	SOUNDCLOUD_CLIENT_ID     = "9e160bd4ed79c346c5b547f36650879c"
	SOUNDCLOUD_CLIENT_SECRET = "de063b99437c4dfb191bf584c4f471c9"
	
	def self.soundcloud_client(options={})
	    options = {
	      :client_id     => SOUNDCLOUD_CLIENT_ID,
	      :client_secret => SOUNDCLOUD_CLIENT_SECRET,
	    }.merge(options)
	
	    Soundcloud.new(options)
	end
  
  
	def soundcloud_client(options={})
	    options= {
	      :expires_at    => soundcloud_expires_at,
	      :access_token  => soundcloud_access_token,
	      :refresh_token => soundcloud_refresh_token
	    }.merge(options)
	    
	    client = self.class.soundcloud_client(options)
	    
	    # define a callback for successful token exchanges
	    # this will make sure that new access_tokens are persisted once an existing 
	    # access_token expired and a new one was retrieved from the soundcloud api
	    client.on_exchange_token do
	      self.update_attributes!({
		:soundcloud_access_token  => client.access_token,
		:soundcloud_refresh_token => client.refresh_token,
		:soundcloud_expires_at    => client.expires_at,
	      })
	    end
	    
	    client
	end
end
