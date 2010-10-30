Feature:
  As a test engineer
  I want to add existing test run reports
  So that stakeholders can easily see the current status

  Background:
    Given I am a new, authenticated user

  @smoke
  Scenario: The front page should show the add report link
    When I am on the front page

    Then I should not see "Sign In"

    And I should see "Add report"

  Scenario Outline: Add new report with valid data
    When I follow "Add report"

    And I select target "Handset", test type "Smokey" and hardware "n990" with date "2010-11-22"
    And I attach the report "<attachment>"

    And submit the form at "upload_report_submit"

    Then I should see "<expected text>" within ".testcase"
    And I should see "<expected link>" within ".testcase"

    And I should see "Publish"
    And I should see "Handset Test Report: n990 Smokey 2010-11-22"

  Examples:
    | attachment     | expected text             | expected link |
    | sample.csv     | Check home screen         | 3921          |
    | bluetooth.xml  | NFT-BT-Device_Scan_C-ITER | Pass          |
    | filesystem.xml | NFT-FS-Read_Data_TMP-THRO | Pass          |
    | sim.xml        | SMOKE-SIM-Get_Languages   | Pass          |

  Scenario: Add new report with invalid filename extension
    When I follow "Add report"
    
    And I select target "Core", test type "Smokey" and hardware "n990"
    And I attach the report "invalid_ext.txt"
    
    And submit the form at "upload_report_submit"
    
    Then I should see "You can only upload files with the extension .xml or .csv"

  Scenario: Add new CSV report with invalid content

    When I follow "Add report"
    
    And I select target "Core", test type "Smokey" and hardware "n990"
    And I attach the report "invalid.csv"
    
    And submit the form at "upload_report_submit"
    
    Then I should see "Incorrect file format"

  Scenario: Add new XML report with invalid content

    When I follow "Add report"
    
    And I select target "Core", test type "Smokey" and hardware "n990"
    And I attach the report "invalid.xml"
    
    And submit the form at "upload_report_submit"
    
    Then I should see "Incorrect file format"

  Scenario: Try to submit without uploading a file

    When I follow "Add report"
    
    And I select target "Core", test type "Smokey" and hardware "n990"
    
    And submit the form at "upload_report_submit"
    
    Then I should see "be blank"

  Scenario: Add new report with saved default target
    When I follow "Add report"
    And I select target "handset_target", test type "Smokey" and hardware "n990"
    And I attach the report "sample.csv"
    And submit the form at "upload_report_submit"
    And submit the form at "upload_report_submit"

    Then I should see "Check home screen" within ".testcase"
    And I should see "Handset" within "h1"

    When I follow "Add report"
    And I select test type "Smokey" and hardware "n990"
    And I attach the report "sample.csv"
    And submit the form at "upload_report_submit"

    Then I should see "Check home screen" within ".testcase"
    And I should see "Handset" within "h1"


