class EventMailer < ActionMailer::Base
	default from: "activation@flyerzero.com"
	add_template_helper(ApplicationHelper)

	def verification_email(event)
		@event = event
		@achievements = Achievement.find_by_email( @event.email );
		@url  = "http://www.flyerzero.com/events/verify/#{@event.validation_hash}"
		@edit_url = "http://www.flyerzero.com/events/edit/#{@event.validation_hash}?event_id=#{event.id}"
		@del_url = "http://www.flyerzero.com/events/delete/#{@event.validation_hash}?event_id=#{event.id}"
		attachments.inline['logo.png'] = Net::HTTP.get('flyerzero.com', '/assets/mainlogo-text.png')
		attachments.inline['flyer.png'] = Net::HTTP.get('flyerzero.com', @event.photo.url(:thumb))
		mail(:to => event.email, :subject => "Verify Your Event on Flyerzero")
	end

end
