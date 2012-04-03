class EventsController < ApplicationController
	def index
	end

	# POST /events
	# POST /events.json
	def create
		event_id = nil
		event_id = params[:event][:event_id] if params[:event][:event_id].length > 0
		@event = Event.new(params[:event])

		if event_id
		      # attach the photo to our event if we have a valid event id
		      parentEvent = Event.find(event_id)
		      @event.photo = parentEvent.photo
		      @event.validation_hash = parentEvent.validation_hash
		else
		      @event.validation_hash = rand(36**16).to_s(36)
		end


		if not @event.save
			render :partial=>"errors.js" and return
		end

		event_id = @event.id if not event_id
		EventMailer.verification_email(@event).deliver
		render :partial=>"create.js", :locals=>{ :event_id=>event_id }
	end

	def verify
		@event = Event.find_by_validation_hash(params[:id])
		flyer = ""
		if @event != nil
			@event.validated = true
			@event.save
			message = "Your event has been verified!"
			flyer = "?flyer=#{@event.id}"
		else
			message = "Oops! We can't find your event anywhere. Sad day."
		end
		redirect_to "/#{flyer}", :notice=>message
	end
end
