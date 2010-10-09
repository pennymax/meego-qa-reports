Feature: Report frontpage shows the Right Stuff

  Scenario: Visiting front page

  When I go to the front page

  Then I should see "MeeGo" within "#logo"
  And I should see "Add report" within "#action"

  And I should see "Core" within "#report_navigation"
  And I should see "Handset" within "#report_navigation"
  And I should see "Netbook" within "#report_navigation"
  And I should see "IVI" within "#report_navigation"

  And I should see "Sanity" within "#report_navigation tr td"
  And I should see "Weekly" within "#report_navigation tr td"
  And I should see "System Functional" within "#report_navigation tr td"

