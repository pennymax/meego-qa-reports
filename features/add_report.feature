Feature:
  As a test engineer
  I want to add existing test run reports
  So that stakeholders can easily see the current status

  @smoke
  Scenario: Checking the adding new report page

    When I am on the front page
    And I follow "Add report" within "#action"

    Then I should see "Upload test data" within "#upload_report"
    And I should see "Publish test report" within "#wizard_progress"

  Scenario: Checking the adding new report page

    When I am on the front page
    And I follow "Add report" within "#action"

    And I fill in "report_test_target" with "Core"
    And I fill in "report_test_type" with "Smokey"
    And I fill in "report_test_hardware" with "n990"

    Then show me the page

    And I follow "#upload_report_submit"

    Then show me the response




