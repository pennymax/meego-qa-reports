Feature: Manage reports

  Background: 
  	Given I have created the "core_aava_sanity" report
  	And I view the report id 1

  Scenario: Viewing a report
    Then I should see "Meego" within "#version_navi"

    And I should see "Check home screen" within ".testcase"
    And I should see "Fail" within ".testcase"
    And I should see "3921" within ".testcase"
    
  Scenario: Printing a report
	When I go to print view

    Then I should not see "Publish test" within "#wizard_progress"

    Then I should see "Check home screen" within ".testcase"
    And I should see "Fail" within ".testcase"
    And I should see "3921" within ".testcase"
	
  Scenario: Editing a report

  Scenario: Deleting a report

