class EventMailer < ActionMailer::Base
	default from: "activation@flyerzero.com"

	def verification_email(event)
		@event = event
		@url  = "http://www.flyerzero.com/events/verify/#{@event.validation_hash}"
		@edit_url = "http://www.flyerzero.com/events/edit/#{@event.validation_hash}?event_id=#{event.id}"
		@del_url = "http://www.flyerzero.com/events/delete/#{@event.validation_hash}?event_id=#{event.id}"
		mail(:to => event.email, :subject => "Verify Your Event on Flyerzero")
	end

end
