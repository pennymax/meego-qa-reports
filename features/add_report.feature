Feature:
  As a test engineer
  I want to add existing test run reports
  So that stakeholders can easily see the current status

  Background:
    Given I am a new, authenticated user

  @smoke
  Scenario: Check the add new report page

    When I am on the front page
    And I follow "Add report" within "#action"

    Then I should see "Upload test data" within "#upload_report"
    And I should see "Publish test report" within "#wizard_progress"


  @smoke
  Scenario Outline: Add new report with sample data

    When I am on the front page
    And I follow "Add report" within "#action"

    And I fill in target "Core", test type "Smokey" and hardware "n990"
    And I attach the report "<attachment>"

    And submit the form at "upload_report_submit"

    And I should see "<expected text>" within ".testcase"
    And I should see "<expected link>" within ".testcase"

  Examples:
    | attachment     | expected text             | expected link |
    | sample.csv     | Check home screen         | 3921          |
    | bluetooth.xml  | NFT-BT-Device_Scan_C-ITER | Pass          |
    | filesystem.xml | NFT-FS-Read_Data_TMP-THRO | Pass          |
    | sim.xml        | SMOKE-SIM-Get_Languages   | Pass          |


