# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# metric_fu is not installed in staging and production environments
begin
  require 'metric_fu'
rescue LoadError
end

Meegoqa::Application.load_tasks
