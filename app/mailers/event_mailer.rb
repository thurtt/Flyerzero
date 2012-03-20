class EventMailer < ActionMailer::Base
	default from: "from@example.com"
	
	def verification_email(event)
		@event = event
		@url  = "http://www.flyerzero.com/event/verify/#{@event.validation_hash}"
		mail(:to => event.email, :subject => "Verify Your Event on Flyerzero")
	end
  
end
