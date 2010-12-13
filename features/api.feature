Feature: REST API
  As an external service
  I want to upload reports via REST API
  So that they can be browsed by users

  Background:
    Given I am an user with a REST authentication token

  Scenario: Uploading test report with HTTP POST
    When the client sends file "sim.xml" via the REST API

    Then the REST result "ok" is "1"
    And I should be able to view the created report

  Scenario: Uploading test report with multiple files and attachments
    When the client sends file with attachments via the REST API
    Then the REST result "ok" is "1"
    And I should be able to view the created report

    Then I should see "SIM" within ".category_name"
    And I should see "BT" within ".category_name"

    And I should see "ajax-loader.gif" within "#file_attachment_list"
    And I should see "icon_alert.gif" within "#file_attachment_list"
    
  Scenario: Sending REST import without valid report file
    When the client sends a request without file via the REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors|uploaded_files" is "can't be blank"

  Scenario: Sending REST import without valid parameters
    When the client sends a request without parameter "target" via the REST API

    Then the REST result "ok" is "0"
    Then the REST result "errors|target" is "can't be blank"
