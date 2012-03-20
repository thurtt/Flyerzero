# Load the rails application
require File.expand_path('../application', __FILE__)

# configure action_mailer
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true

# Initialize the rails application
Flyerzero::Application.initialize!
