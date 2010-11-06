set :application, "qa-reports.meego.com"
set :user, "www-data"
set :rails_env, "production"

# Use absolute paths in order to avoid problems with scp
set :deploy_to, "/home/#{user}/#{application}"

ssh_options[:user] = "www-data"
ssh_options[:port] = 43398

server "qa-reports.meego.com", :app, :web, :db, :primary => true

set :dbuser, "meego"
set :dbhost, "localhost"
set :database, "meego_qa_reports_production"

namespace :db do
  desc "Get the database password from user"
  task :get_password do
    set(:dbpass) do
      Capistrano::CLI.ui.ask "Enter mysql production password: "
    end
  end

  task :backup_name, :only => { :primary => true } do
    run "mkdir -p #{shared_path}/db_dumps"
    set :backup_file, "#{shared_path}/db_dumps/#{database}.sql"
  end

  desc "Dump database to backup file"
  task :dump, :roles => :db, :only => {:primary => true} do
    backup_name
    get_password
    run "mysqldump --add-drop-table -u #{dbuser} -h #{dbhost} -p#{dbpass} #{database} | bzip2 -c > #{backup_file}.bz2"
    get "#{backup_file}.bz2", "./#{database}.sql.bz2"
  end

  desc "Fetch the file and dump it to the local database"
end
