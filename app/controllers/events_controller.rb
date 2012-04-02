class EventsController < ApplicationController
	def index
	end

	# POST /events
	# POST /events.json
	def create
		event_id = nil
		event_id = params[:event][:event_id] if params[:event][:event_id].length > 0
		@event = Event.new(params[:event])
		@event.validation_hash = rand(36**16).to_s(36)
		# attach the photo to our event if we have a valid event id
		@event.photo = Event.find(event_id).photo if event_id

		if not @event.save
			render :partial=>"errors.js" and return
		end

		event_id = @event.id if not event_id
		EventMailer.verification_email(@event).deliver
		render :partial=>"create.js", :locals=>{ :event_id=>event_id }
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
