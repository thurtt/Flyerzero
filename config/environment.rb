# Load the rails application
require File.expand_path('../application', __FILE__)

# configure action_mailer
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :address => 'mail.flyerzero.com',
  :port => 587,
  :domain => 'flyerzero.com',
  :authentication => :login,
  :user_name => 'username@flyerzero.com',
  :password => 'password'
}
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
config.action_mailer.default_charset = 'utf-8'

# Initialize the rails application
Flyerzero::Application.initialize!
