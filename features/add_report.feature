Feature:
  As a test engineer
  I want to add existing test run reports
  So that stakeholders can easily see the current status

  @smoke
  Scenario: Check the add new report page

    When I am on the front page
    And I follow "Add report" within "#action"

    Then I should see "Upload test data" within "#upload_report"
    And I should see "Publish test report" within "#wizard_progress"

  @smoke
  Scenario: Add new report with valid data

    When I am on the front page
    And I follow "Add report" within "#action"

    And fill in "meego_test_session[target]" with "Core"
    And fill in "meego_test_session[testtype]" with "Smokey"
    And fill in "meego_test_session[hwproduct]" with "n990"

    And attach the file "features/resources/sample.csv" to "meego_test_session[uploaded_files][]" within "#browse"

    And submit the form at "upload_report_submit"

    Then I should see "Check home screen" within ".testcase"
    And I should see "Fail" within ".testcase"
    And I should see "3921" within ".testcase"
