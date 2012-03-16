class EventsController < ApplicationController
	def index
	end

	# POST /events
	# POST /events.json
	def create
		partial = "submit"
		puts "$$$$ #{params.inspect}"
		@event = Event.new(params[:event])
		#@event.expiry = Time._load( params[:event][:expiry] )
		@event.validation_hash = rand(36**16).to_s(36)
		if @event.save
			partial = "created"
		end

		render :partial=>"create.js", :locals=>{ :partial=>partial }
	end

	def upload
		puts params.inspect
		respond_to do |format|
			format.json{ render :nothing => true }
		end
	end

end
