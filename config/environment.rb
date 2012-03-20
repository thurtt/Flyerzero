# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Flyerzero::Application.initialize!

# configure action_mailer
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = false
ActionMailer::Base.perform_deliveries = true