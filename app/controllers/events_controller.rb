class EventsController < ApplicationController
	before_filter :authenticate, :except=>[ :view ]
	protect_from_forgery :except => [ :create, :update ]
	
	include ApplicationHelper
	
	def index
	end
	
	def view
		@event = Event.find(params[:event_id])
		render :layout=>"event"
	end
	
	def submit
		
		
		if (params[:event_id])
			@event = Event.find( params[:event_id] )
			@edit = true
			@event_id = @event.id
			@validation = @event.validation_hash
			
			if @event.email != session[:email]
				redirect_to "/item?event_id=" + @event.id.to_s() and return
			end
		else
			@event = Event.new
			@event.email = session[:email]
		end
	end

	# POST /events
	# POST /events.json
	def create
		
		
		event_id = nil
		imageurl = nil
		
		event_id = params[:event][:event_id] if params[:event][:event_id].length > 0
		imageurl = params[:imgurl] if params[:imgurl]

		
		
		@event = Event.new(params[:event])
		partial = "create"
		
		if Event.find_by_fbevent(params[:event][:fbURL]) && params[:event][:fbURL] != nil
			partial = "errors"
		else
			if event_id
			      # attach the photo to our event if we have a valid event id
			      parentEvent = Event.find(event_id)
			      @event.photo = parentEvent.photo
			      @event.validation_hash = parentEvent.validation_hash
			else
			      @event.validation_hash = rand(36**16).to_s(36)
			end
	
			if imageurl
				@event.image_from_url(imageurl)
			end
			
			@event.validated = true

			# add the venue to our venues if it's not already in there.
			Venue.add_venue_if_necessary(@event.venue_id)

			# pull out our hashtags and save them
			@event.media.scan(/\s(#[a-zA-Z0-9_]+)/) { |tag| 
			puts tag
			@event.tag_list << tag }
			
			#let's just enforce this here.
			@event.email = session[:email]
			
			if not @event.save
			      partial = "errors"
			end
		end

		if params[:send_to_facebook] == "on" && ENV['RAILS_ENV'] != 'development'
			#Post to facebook!
			
			endpoint = 'https://graph.facebook.com/' + session[:user_id] + '/photos?access_token=' + session[:access_token] + '&message=' + URI.escape(@event.media)
			imgURL = "http://www.flyerzero.com#{@event.photo.url(:large)}"
			
			response = RestClient.post endpoint, :url=>imgURL
		
			#fb_photo = (ActiveSupport::JSON.decode(response))
		
		end
		
		event_id = @event.id if not event_id
		#EventMailer.verification_email(@event).deliver
		respond_to do |format|
		    format.html { render :partial=>partial, :locals=>{ :event_id=>event_id, :photo=>@event.photo.url(:small) } }
		end
	end

	def update
		partial = "update"
		@event = Event.find_by_id_and_validation_hash( params[:event][:id], params[:event][:validation_hash] )
		
		if @event.email != session[:email]
			redirect_to "/item?event_id=" + @event.id.to_s() and return
		end
			
		if not @event.update_attributes( params[:event] )
			partial = "errors"
		end
		respond_to do |format|
			format.html { render :partial=>partial, :locals=>{ :flyer_id=>@event.id } }
		end
	end

	def delete
		if not @authenticated
		      message = "Oops! We can't find your event anywhere. Sad day."
		else
			event = Event.find( params[:event_id] )
			
			if event.email != session[:email]
				redirect_to "/item?event_id=" + event.id.to_s() and return
			end
			
			event.delete
			message = "Your event has been deleted!"
		end
		redirect_to "/", :notice=>message
	end

	def edit
		if not @authenticated
		      message = "Oops! We can't find your event anywhere. Sad day."
		      redirect_to "/", :notice=>message and return
		end

		event = Event.find( params[:event_id ] )
		if event.email != session[:email]
			redirect_to "/item?event_id=" + event.id.to_s() and return
		end
		render "board/index", :locals=>{ :edit=>true, :event_id=>event.id, :validation=>params[:id] }
	end


	def authenticate
	      	@authenticated = false
	      	
	      	if params[:access_token]
	      		authenticate_token(params[:access_token])
	      	end
	      	
	      	if session[:authenticated] == true
	      		@authenticated = true
	      	end
	      	
	      	if not @authenticated
		      redirect_to "/" and return
		end
	end
	
	def visit
		message = "Visitation failed."
		
		#session[:name].split(' ')[0]
		#session[:email]
		visitor = Visitor.new(params[:visitor])
		visitor.email = session[:email] # you can't spoof us here
		visitor.name = visitor[:name].split(' ')[0] #or here, but it doesn't matter.
		if visitor.save
			message="Visitation complete!"
		end
		render :text=>message
	end
end
