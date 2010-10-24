set :application, "qa-reports.meego.com"
set :repository,  "git@github.com:leonidas/meego-qa-reports.git"
set :user, "www-data"
set :use_sudo, false
set :rails_env, "production"

ssh_options[:forward_agent] = true
ssh_options[:user] = "www-data"
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "leonidas")]
ssh_options[:port] = 43398

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
set :deploy_to, "/home/#{user}/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
# see a full list by running "gem contents capistrano | grep 'scm/'"

role :app, "qa-reports.meego.com"
role :web, "qa-reports.meego.com"
role :db,  "qa-reports.meego.com", :primary => true
