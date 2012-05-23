# This is used to make sure the custom databse.yml file gets migrated with each deployment
# There may be a better way to do this, but here is the site I referenced: http://www.simonecarletti.com/blog/2009/06/capistrano-and-database-yml/
require "./config/capistrano_database"
require "./config/capistrano_email"

set :application, "flyerzero"
set :repository,  "git://github.com/thurtt/Flyerzero.git"
set(:user) { Capistrano::CLI.ui.ask("User name: ") }
set :appuser, "fzu"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm_username, user
set :runner, user
set :use_sudo, false
set :branch, "master"
set :deploy_via, :checkout
set :git_shallow_clone, 1
set :deploy_to, "/home/#{appuser}/#{application}"


default_run_options[:pty] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_dsa")]
role :web, "www.flyerzero.com"                          # Your HTTP server, Apache/etc
role :app, "www.flyerzero.com"                          # This may be the same as your `Web` server
role :db,  "www.flyerzero.com", :primary => true # This is where Rails migrations will run

# global rvm integration
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2-p290@rails313'
set :rvm_type, :system

# This line runs the bundler
require "bundler/capistrano"

# and this line compiles the asset pipeline
load 'deploy/assets'

# override the double compile
Rake::Task['assets:precompile:all'].clear
namespace :assets do
  namespace :precompile do
    task :all do
      Rake::Task['assets:precompile:primary'].invoke
      # ruby_rake_task("assets:precompile:nondigest", false) if Rails.application.config.assets.digest
    end
  end
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

task :refresh_sitemaps do
  run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake sitemap:refresh"
end

after "deploy", "deploy:migrate", "refresh_sitemaps"
