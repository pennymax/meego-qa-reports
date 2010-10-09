Feature: Manage report_front_pages
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new report_front_page
    Given I am on the new report_front_page page
    And I press "Create"

  Scenario: Delete report_front_page
    Given the following report_front_pages:
      ||
      ||
      ||
      ||
      ||
    When I delete the 3rd report_front_page
    Then I should see the following report_front_pages:
      ||
      ||
      ||
      ||
