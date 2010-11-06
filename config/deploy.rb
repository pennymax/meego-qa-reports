# Must be set before requireing multisage
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'config/deploy/capistrano_database_yml'
require 'bundler/capistrano'

set :use_sudo, false
set :copy_compression, :zip

set :scm, :git
set :repository, "http://github.com/leonidas/meego-qa-reports.git" 
set :deploy_via, :remote_cache

ssh_options[:forward_agent] = true

# If you have previously been relying upon the code to start, stop
# and restart your mongrel application, or if you rely on the database
# migration code, please uncomment the lines you require below

# If you are deploying a rails app you probably need these:

# load 'ext/rails-database-migrations.rb'
# load 'ext/rails-shared-directories.rb'

# There are also new utility libaries shipped with the core these
# include the following, please see individual files for more
# documentation, or run `cap -vT` with the following lines commented
# out to see what they make available.

# load 'ext/spinner.rb'              # Designed for use with script/spin
# load 'ext/passenger-mod-rails.rb'  # Restart task for use with mod_rails
# load 'ext/web-disable-enable.rb'   # Gives you web:disable and web:enable

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

# If you aren't using Subversion to manage your source code, specify
# your SCM below:

after "deploy:setup" do
  # Create shared directories
  run "mkdir #{shared_path}/reports"
  run "mkdir #{shared_path}/reports/tmp"
end

after "deploy:symlink" do
  # Remove local directories
  run "rm -fr #{current_path}/public/reports"
  
  # Link to shared folders
  run "ln -nfs #{shared_path}/reports #{current_path}/public/"

  run "ln -nfs #{shared_path}/config/registeration_token #{current_path}/config/registeration_token"
end

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Start the app server"
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

end

