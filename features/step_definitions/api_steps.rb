Given /^I am an user with a REST authentication token$/ do
  Given %{I have one user "John Restless" with email "resting@man.net" and password "secretpass" and token "foobar"}
end

When /^the client sends file "([^"]*)" via the REST API$/ do |file|
  post "/api/import?auth_token=foobar", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml"),
      "release_version" => "1.2",
      "target"          => "Core",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
  response.should be_success
end

When /^the client sends file "([^"]*)" via the REST API with RESTful parameters$/ do |file|
  post "/api/import?auth_token=foobar&release_version=1.2&target=Core&testtype=automated&hwproduct=N900", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml")
  }
  response.should be_success
end


When /^the client sends file with attachments via the REST API$/ do
  post "/api/import?auth_token=foobar", {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/bluetooth.xml", "text/xml"),
      "attachment.1"    => Rack::Test::UploadedFile.new("public/images/ajax-loader.gif", "image/gif"),
      "attachment.2"    => Rack::Test::UploadedFile.new("public/images/icon_alert.gif", "image/gif"),
      "release_version" => "1.2",
      "target"          => "Core",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
  response.should be_success
end


When /^the client sends a request without file via the REST API$/ do
  post "/api/import?auth_token=foobar", {
      "release_version" => "1.2",
      "target"          => "Core",
      "tested_at"       => "20101130",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
  response.should be_success
end

When /^the client sends a request without parameter "target" via the REST API$/ do
  post "/api/import?auth_token=foobar", {
      "report"     => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
      "testtype"     => "automated",
      "hwproduct"    => "N900"
  }
  response.should be_success
end

When /^the client sends a request with extra parameter "([^"]*)" via the REST API$/ do |extra|
  post "/api/import?auth_token=foobar&release_version=1.2&target=Core&testtype=automated&hwproduct=N900&" + extra, {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml")
  }
  response.should be_success

end

Then /^I should be able to view the created report$/ do
  Then %{I view the report "1.2/Core/Automated/N900"}
end

Then /^the REST result "([^"]*)" is "([^"]*)"$/ do |key, value|
  json = ActiveSupport::JSON.decode(@response.body)
  key.split('|').each { |item| json = json[item] }
  json.should == value
end
