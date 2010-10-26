Feature:
  As a MeeGo QA Reports developer
  I want to ensure that all the landing pages have appropriate headers
  So that I know that at least the very basic stuff works

  @smoke
  Scenario: Visiting the front page

    When I go to the front page

    Then I should see "MeeGo" within "#logo"
    And I should see the sign in link without ability to add report
    And I should see the main navigation columns



