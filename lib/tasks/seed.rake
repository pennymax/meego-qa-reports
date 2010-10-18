namespace :db do
  namespace :seed do
    require 'db/seed_tables'

    desc "dump the tables holding seed data to db/RAILS_ENV_seed.sql. SEED_TABLES need to be defined in config/environment.rb!!!"
    task :dump => :environment do
      config = ActiveRecord::Base.configurations[RAILS_ENV]
      dump_cmd = "echo '.dump #{SEED_TABLES.join(" ")}' | sqlite3 #{config['database']} | fgrep INSERT > db/#{RAILS_ENV}_seed.sql"
      system(dump_cmd)
    end

    desc "load the dumped seed data from db/RAILS_ENV_seed.sql into the test database"
    task :load => :environment do
      config = ActiveRecord::Base.configurations[RAILS_ENV]
      load_cmd = "sqlite3 #{config['database']} < db/#{RAILS_ENV}_seed.sql"
      system(load_cmd)
     end
  end
end