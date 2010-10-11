Then /^show me the response$/ do
  puts page.body
end

When /submit the form(?: at "([^"]*)")?$/ do |form_id|
  form_id ? click(form_id) : click("input[@type='submit']")
end