Feature: Manage reports

  Background: 
  	Given I have created the "sample" report
  	And I view the "sample" report page

  Scenario: Viewing a report
    Then I should see "Publish test" within "#wizard_progress"

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

