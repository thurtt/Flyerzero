class EventsController < ApplicationController
	def index
	end
	
	# POST /events
	# POST /events.json
	def create
		@event = Event.new(params[:event])
		#@event.expiry = Time._load( params[:event][:expiry] )
		@event.validation_hash = rand(36**16).to_s(36)
		if @event.save
			render :parital=>"created"
		else
			render :partial=>"submit"
		end
	end
	
end
