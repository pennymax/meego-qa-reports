Feature: REST API
  As an external service
  I want to upload reports via REST API
  So that they can be browsed by users

  Scenario: Uploading test report with HTTP POST
    Given I am an user with a REST authentication token
    And the client sends file "sim.xml" via REST API

    Then the REST result should be '{"ok":"1"}'
    And I should be able to view the created report
