class EventsController < ApplicationController
	before_filter :authorize, :except=>[:create, :verify ]
	def index
	end

	# POST /events
	# POST /events.json
	def create
		event_id = nil
		event_id = params[:event][:event_id] if params[:event][:event_id].length > 0

		if params[:edit]
		    @event = Event.find( event_id )
		else
		    @event = Event.new(params[:event])
		end
		partial = "create"


		if event_id
		      # attach the photo to our event if we have a valid event id
		      parentEvent = Event.find(event_id)
		      @event.photo = parentEvent.photo
		      @event.validation_hash = parentEvent.validation_hash
		else
		      @event.validation_hash = rand(36**16).to_s(36)
		end


		if not @event.save
		      partial = "errors"
		end

		event_id = @event.id if not event_id
		EventMailer.verification_email(@event).deliver
		respond_to do |format|
		    format.html { render :partial=>partial, :locals=>{ :event_id=>event_id, :photo=>@event.photo.url(:thumb) } }
		end
	end

	def delete
		if not @authorized
		      message = "Oops! We can't find your event anywhere. Sad day."
		else
		      event = Event.find( params[:event_id] )
		      @event.delete
		      message = "Your event has been deleted!"
		end
		redirect_to "/", :notice=>message
	end

	def edit
		if not @authorized
		      message = "Oops! We can't find your event anywhere. Sad day."
		      redirect_to "/", :notice=>message and return
		end

		event = Event.find( params[:event_id ] )
		render "board/index", :locals=>{ :edit=>true, :event_id=>event.id, :validation=>params[:id] }
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

	def authorize
	      	@authorized = false
	      	event = Event.find( params[:event_id] )
		if event and event.validation_hash == params[:id]
			@authorized = true
		end
	end
end
