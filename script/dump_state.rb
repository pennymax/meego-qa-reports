#!/usr/bin/env ruby

# Dumps current state from dev environment to named SQL file under features/resources
# Usage: script/dump_state.rb <basename>
#
# Eg. script/dump_state.rb cheezburger # => features/resources/cheezburger_state.sql
require 'config/environment'

module StateDumper
  def included_tables
    ignored_tables = %w(schema_migrations)
    ActiveRecord::Base.connection.tables.reject {|t| ignored_tables.include?(t)}
  end

  def dump(outfile_base)
    state_env = 'development'
    config = ActiveRecord::Base.configurations[state_env]

    out_path = File.join("features/resources", "#{outfile_base}_state.sql")
    dump_cmd = "echo '.dump #{included_tables.join(" ")}' | sqlite3 #{config['database']} | fgrep INSERT > #{out_path}"
    system(dump_cmd)
  end
end

if __FILE__ == $0
  include StateDumper
  dump(ARGV[0])
end
