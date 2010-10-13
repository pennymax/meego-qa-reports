Then /^show me the response$/ do
  puts page.body.inspect
end

When /submit the form(?: at "([^"]*)")?$/ do |form_id|
  target = form_id || "input[@type='submit']"
  click(target)
end