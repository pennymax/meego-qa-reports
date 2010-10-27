Feature: Manage reports

  Background:
    Given I am a new, authenticated user
    And I have created the "Core/Sanity/Aava" report

  @smoke
  Scenario: Viewing a report
    When I view the report "Core/Sanity/Aava"

    Then I should see "Meego" within "#version_navi"
    And I should see the header

    And I should see "Check home screen" within ".testcase"
    And I should see "Fail" within ".testcase"
    And I should see "3921" within ".testcase"

  @smoke
  Scenario: Printing a report
    When I view the report "Core/Sanity/Aava"

	And I click to print the report

    And I should not see the header

    And I should see "Check home screen" within ".testcase"
    And I should see "Fail" within ".testcase"
    And I should see "3921" within ".testcase"

  @smoke
  Scenario: Editing a report
    When I view the report "Core/Sanity/Aava"
    And I click to edit the report

    Then I should see "Edit the report information" within ".notification"
    And I should see "Test Objective" within "#test_objective"
    And I should see "Edit" within "#test_objective .edit"

  Scenario: Deleting a report    
    When I view the report "Core/Sanity/Aava"
    And I click to delete the report

    Then I should see "Are you sure you want to delete" within "#delete-dialog"


