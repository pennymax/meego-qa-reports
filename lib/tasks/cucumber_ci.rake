require 'rubygems'

begin
  require 'cucumber'
  require 'cucumber/rake/task'

  namespace :cucumber do
    Cucumber::Rake::Task.new({:ci => 'db:test:prepare'}, 'Run features in CI environment with rcov and JUnit output') do |t|
      t.cucumber_opts = "features --format junit --out cucumber"
      t.rcov = true
    end

    Cucumber::Rake::Task.new({:rcov => 'db:test:prepare'}, 'Run rcov for cucs') do |t|
      t.rcov = true
    end
  end

rescue LoadError
  # cucumber not available in production env
end
