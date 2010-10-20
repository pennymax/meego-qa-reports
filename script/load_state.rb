#!/usr/bin/env ruby
require 'config/environment'

module StateLoader
  def included_tables
    ignored_tables = %w(schema_migrations)
    ActiveRecord::Base.connection.tables.reject {|t| ignored_tables.include?(t)}
  end

  # load SQL from given path to database used in env (defaults to test).
  def load(fpath, env=nil)
    raise ArgumentError, "missing input file" unless File.exist?(fpath)
    state_env = env || 'test'
    config = ActiveRecord::Base.configurations[state_env]

    load_cmd = "sqlite3 #{config['database']} < #{fpath}"
    system(load_cmd)
  end
end

if __FILE__ == $0
  include StateLoader
  load(ARGV[0])
end
