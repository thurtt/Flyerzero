unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :email do
    task :setup, :except => { :no_release => true } do

      default_template = <<-EOF
      development:
	address: smtp.gmail.com
	port: 587
	authentication: plain
	user_name: xxx
	password: yyy
	enable_starttls_auto: true
      production:
	address: mail.flyerzero.com
	port: 587
	authentication: login
	user_name: xxx
	password: yyy
      EOF

      location = fetch(:template_dir, "config/deploy") + '/email.yml.erb'
      template = File.file?(location) ? File.read(location) : default_template

      config = ERB.new(template)

      run "mkdir -p #{shared_path}/config"
      put config.result(binding), "#{shared_path}/config/email.yml"
    end

    task :symlink, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/config/email.yml #{release_path}/config/email.yml"
    end

  end

  after "deploy:setup",           "email:setup"   unless fetch(:skip_email_setup, false)
  after "deploy:finalize_update", "email:symlink"

end