require 'rubygems'

begin
  require 'cucumber'
  require 'cucumber/rake/task'

  namespace :cucumber do
    Cucumber::Rake::Task.new({:rcov => 'db:test:prepare'}, 'Run rcov for cucs') do |t|
      t.rcov = true
      t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/}
    end
  end

rescue LoadError
  # cucumber not available in production env
end
