source 'http://rubygems.org'

gem 'rails', '3.0.1'

group :staging, :production do
  gem 'mysql'
  gem 'newrelic_rpm'
end

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'ruby-debug'
  gem 'mysql'
end

group :development, :test do # so that we can call rspec tasks from dev env
  gem 'rspec', '2.0.1'
  gem 'rspec-rails', '2.0.1'
end

group :test do
  gem 'capybara'
  gem 'capybara-envjs'
  gem 'cucumber'
  gem 'rcov', :require => false
  gem 'culerity'
  gem 'celerity', :require => false
  gem 'launchy'
  gem 'cucumber-rails'
  gem 'ZenTest', '4.4.0'
  gem 'autotest'
  gem 'autotest-rails'
  gem 'metric_fu', :git => "git://github.com/pyykkis/metric_fu.git"
  gem 'ruby-debug'
end

gem 'nokogiri'
gem 'bitly'
gem 'devise', '1.1.3'
gem 'fastercsv'
gem 'rack', :git => "git://github.com/rack/rack.git" # Use next release when available
