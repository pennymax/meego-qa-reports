set :application, "meego.qa.leonidasoy.fi"
set :user, "leonidas"
set :rails_env, "staging"

# Use absolute paths in order to avoid problems with scp
set :deploy_to, "/home/#{user}/sites/#{application}"

ssh_options[:port] = 31915
ssh_options[:user] = "leonidas"

server "staging.leonidasoy.fi", :app, :web, :db, :primary => true

