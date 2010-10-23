module StateLoader
  def included_tables
    ignored_tables = %w(schema_migrations)
    ActiveRecord::Base.connection.tables.reject { |t| ignored_tables.include?(t) }
  end

  # load SQL from given path to database used in env (defaults to test).
  def load(fpath, env=nil)
    raise ArgumentError, "missing input file" unless File.exists?(fpath)
    state_env = env || 'test'
    config = ActiveRecord::Base.configurations[state_env]

    cmd = "sqlite3 #{config['database']} < #{fpath}"
    system(cmd)
  end


  def dump(outfile_base)
    state_env = 'development'
    config = ActiveRecord::Base.configurations[state_env]

    out_path = File.join("features/resources", "#{outfile_base}_state.sql")
    cmd = "echo '.dump #{included_tables.join(" ")}' | sqlite3 #{config['database']} | fgrep INSERT > #{out_path}"
    system(cmd)
  end
end
