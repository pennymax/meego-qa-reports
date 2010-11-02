set :application, "qa-reports.meego.com"
set :user, "www-data"
set :rails_env, "production"

# Use absolute paths in order to avoid problems with scp
set :deploy_to, "/home/#{user}/#{application}"

ssh_options[:user] = "www-data"
ssh_options[:port] = 43398

server "qa-reports.meego.com", :app, :web, :db, :primary => true

