Feature:
  As a MeeGo QA Reports developer
  I want to ensure that all the landing pages have appropriate headers
  So that I know that at least the very basic stuff works

  @smoke
  Scenario: Visiting the front page

  When I go to the front page

  Then I should see "MeeGo" within "#logo"

  And I should see "Add report" within "#action"

  And I should see "Core" within "#report_navigation"
  And I should see "Handset" within "#report_navigation"
  And I should see "Netbook" within "#report_navigation"
  And I should see "IVI" within "#report_navigation"


