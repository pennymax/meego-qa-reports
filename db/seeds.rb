# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if Rails.env == "development" or Rails.env == "staging"
  User.create! :password => 'testpass',
               :email => 'test@leonidasoy.fi',
               :name => "Jean-Claude Van Damme" unless User.exists? :email => 'test@leonidasoy.fi'
end

if Rails.env == "staging" and MeegoTestSession.count < 10000 # ensure there's always 10000 reports on database
  testuser = User.find_by_email("test@leonidasoy.fi")

  fpath = File.join(Rails.root, "features", "resources", "sample.csv")
  tmpfile_path = File.join(Rails.root, "tmp", "tmp_file.csv")

  File.open(fpath, "r") do |csv_file|
    File.open(tmpfile_path, "w") do |tmp_file|
      tmp_file.write csv_file.read
    end
  end

  10000.times do
    session = MeegoTestSession.new(
      "build_txt" => "",
      "qa_summary_txt" => "",
      "uploaded_files" => [tmpfile_path],
      "testtype" => "Acceptance",
      "hwproduct" => "N900",
      "environment_txt" => "",
      "issue_summary_txt" => "",
      "target" => "Core",
      "objective_txt" => ""
    )
    session.generate_defaults!
    session.tested_at = Time.now
    session.author = testuser
    session.editor = testuser
    session.published = true
    session.save
  end

end
