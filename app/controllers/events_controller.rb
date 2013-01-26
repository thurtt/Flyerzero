class EventsController < ApplicationController
	before_filter :authorize, :except=>[:create, :verify, :update, :share ]
	def index
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
			
			if not @event.save
			      partial = "errors"
			end
		end

		event_id = @event.id if not event_id
		EventMailer.verification_email(@event).deliver
		respond_to do |format|
		    format.html { render :partial=>partial, :locals=>{ :event_id=>event_id, :photo=>@event.photo.url(:small) } }
		end
	end

	def update
		partial = "update"
		@event = Event.find_by_id_and_validation_hash( params[:event][:id], params[:event][:validation_hash] )
		if not @event.update_attributes( params[:event] )
			partial = "errors"
		end
		respond_to do |format|
			format.html { render :partial=>partial, :locals=>{ :flyer_id=>@event.id } }
		end
	end

	def delete
		if not @authorized
		      message = "Oops! We can't find your event anywhere. Sad day."
		else
		      event = Event.find( params[:event_id] )
		      event.delete
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
		@events = Event.where( 'validation_hash = ?', params[:id] )

		no_cool_points_for_you = false

		flyer = ""
		if @events != nil
			@events.each do | event |
				if event.validated != 1
					event.validated = true
					event.save
				else
					no_cool_points_for_you = true
				end
			end
			email = @events[0].email

			achieve = Achievement.find_by_email(email)

			if no_cool_points_for_you == false
				#this is the first validation attempt, which is good.
				if !achieve
					achieve = Achievement.new( { :email=>email, :points=>0, :currency=>0 } )
				end
				achieve.complete
				achieve.save
			end
			message = "Your event has been verified!<br \><span style='font-size:0.6em;'>"
			message += "#{email} now has #{achieve.points} cool points.<br />"
			message += "Get another: "
			message += "<a href='http://www.facebook.com/sharer.php?&u=http://www.flyerzero.com/?flyer=#{params[:event_id]}&t=Flyer Zero Event' target='_blank' onclick='return getSharePoints(\"#{params[:event_id]}\");'>"
			message += "<img src='/assets/facebook_share_button.jpeg' alt='Facebook' /></a>"
			message += "</span>"
			flyer = "?flyer=#{params[:event_id]}"
		else
			message = "Oops! We can't find your event anywhere. Sad day."
		end
		redirect_to "/#{flyer}", :notice=>message
	end

	def share
		@event = Event.find(params[:id])
		session[:shared] = "" if session[:shared] == nil
		if @event != nil
			achieve = Achievement.find_by_email(@event.email)
			if @event.validated && !session[:shared].include?(@event.validation_hash)
				#this is the first validation attempt, which is good.

				if !achieve
					achieve = Achievement.new( { :email=>@event.email, :points=>0, :currency=>0 } )
				end
				achieve.complete
				achieve.save
				session[:shared] += "#{@event.validation_hash},"
			end
			message = "This event has been shared!<br \><span style='font-size:0.6em;'>#{@event.email} now has #{achieve.points} cool points.</span>"
			flyer = "?flyer=#{@event.id}"
		else
			message = "Oops! We can't find your event anywhere. Sad day."
		end
		render :text=>message

	end

	def authorize
	      	@authorized = false
	      	event = Event.find( params[:event_id] )
		if event and event.validation_hash == params[:id]
			@authorized = true
		end
	end
end
