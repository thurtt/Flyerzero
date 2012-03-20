class EventsController < ApplicationController
	def index
	end

	# POST /events
	# POST /events.json
	def create
		partial = "submit"
		@event = Event.new(params[:event])
		#@event.expiry = Time._load( params[:event][:expiry] )
		@event.validation_hash = rand(36**16).to_s(36)
		if not @event.save
			render :partial=>"errors" and return
		end
		
		EventMailer.verification_email(@event).deliver
		render :partial=>"created"
	end
end
