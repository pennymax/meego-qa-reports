set :stages, %w(staging production)
set :default_stage, "staging"

#set :copy_compression, :zip

require 'capistrano/ext/multistage'
require 'config/capistrano_database_yml'
require 'bundler/capistrano'

set :app_env, "production"
set :rails_env, "production"
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
set :scm, :git

after "deploy:symlink" do
  run "ln -nfs #{shared_path}/reports #{current_path}/public/"
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

