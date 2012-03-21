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
		respond_to do |format|
			format.js {render :partial=>"create"}
		end
	end

	def verify
		@event = Event.find_by_validation_hash(params[:id])
		if @event != nil
			@event.validated = true
			@event.save
			message = "Your event has been verified!"
		else
			message = "Oops! We can't find your event anywhere. Sad day."
		end
		redirect_to "/", :notice=>message
	end
end
