require 'rubygems'

namespace :db do
  task :import do

    `bunzip2 meego_qa_reports_production.sql.bz2`
    `mysql -u meego meego_qa_reports_development -p < meego_qa_reports_production.sql`

  end
end

