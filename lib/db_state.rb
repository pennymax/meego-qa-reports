module DBState
  extend self

  def included_tables
    ignored_tables = %w(schema_migrations)
    ActiveRecord::Base.connection.tables.reject { |t| ignored_tables.include?(t) }
  end

  # load SQL from given path to database used in env (defaults to test).
  def load(fpath, env=nil)
    raise ArgumentError, "missing input file" unless File.exists?(fpath)
    state_env = env || 'test'
    config = ActiveRecord::Base.configurations[state_env]

    clear_tables(config)

    cmd = "sqlite3 #{config['database']} < #{fpath} >> tmp/sqlite3.log 2>&1"
    system(cmd)
  end


  def clear_tables(config)
    drops = included_tables.map {|t| "delete from #{t};"}.join("\n")
    system("echo '#{drops}' | sqlite3 #{config['database']} >> tmp/sqlite3.log 2>&1")
  end

  def dump(outfile_base)
    state_env = 'development'
    config = ActiveRecord::Base.configurations[state_env]

    out_path = File.join("features/resources", "#{outfile_base}_state.sql")
    cmd = "echo '.dump #{included_tables.join(" ")}' | sqlite3 #{config['database']} | fgrep INSERT > #{out_path}"
    system(cmd)
  end
end
