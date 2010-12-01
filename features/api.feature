Feature: REST API
  As an external service
  I want to upload reports via REST API
  So that they can be browsed by users

  Scenario: Uploading test report with HTTP POST
    Given I am an user with a REST authentication token
    And the client sends file "sim.xml" via REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report


  Scenario: Sending REST import without valid report file
    Given I am an user with a REST authentication token
    And the client sends a request without file via REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors|uploaded_files" is "can't be blank"

  Scenario: Sending REST import without valid parameters
    Given I am an user with a REST authentication token
    And the client sends a request without parameter "target" via REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors|target" is "can't be blank"