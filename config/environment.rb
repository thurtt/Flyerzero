# Load the rails application
require File.expand_path('../application', __FILE__)

# configure action_mailer
config.action_mailer.delivery_method = :smtp
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true

# Initialize the rails application
Flyerzero::Application.initialize!
