Feature: Printing reports
  In order to take test report results with me everywhere and make notes
  As a [stakeholder]
  I want to have printable reports
  
  Scenario: Viewing print layout
    Given I am viewing the "sample" report
    And I select the print css

	Then I should not see the main logo
