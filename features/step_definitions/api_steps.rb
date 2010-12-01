Given /^I am an user with a REST authentication token$/ do
  Given %{I have one user "John Longbottom" with email "resting@man.net" and password "secretpass" and token "foobar"}
end

When /^the client sends file "([^"]*)" via REST API$/ do |file|
  post "/api/import?auth_token=foobar", {
      "file"            => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml"),
      "release_version" => "1.2",
      "target"          => "Core",
      "tested_at"       => "20101130",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
end

Then /^I should be able to view the created report$/ do
  Then %{I view the report "1.2/Core/Automated/N900"}
end
