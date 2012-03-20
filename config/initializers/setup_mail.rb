if Rails.env == 'production'
  email_settings = YAML::load(File.open("#{Rails.root.to_s}../shared/config/email.yml"))
end

if Rails.env == 'development'
  email_settings = YAML::load(File.open("#{Rails.root.to_s}/config/email.yml"))
end

if Rails.env != 'test'
  ActionMailer::Base.smtp_settings = email_settings[Rails.env] unless email_settings[Rails.env].nil?
end