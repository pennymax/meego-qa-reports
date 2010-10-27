Feature: Logging in
  In order to submit test reports to the system
  MeeGo test engineers
  Want to be able to log in to MeeGoQA

  Scenario: Log in with correct email address and password
    Given I have one user "John Longbottom" with email "tester@meego.com" and password "testing4ever"
    And I'm not logged in

    Given there exists a report for "Handset/Sanity/N900"

    When I go to the front page
    #And there's MeeGo 1.0, 1.1 and 1.2 releases
    And I view the report "Handset/Sanity/N900"

    When I log in with email "tester@meego.com" and password "testing4ever"
    Then I should return to report "Handset/Sanity/N900" and see "John Longbottom" and a "Log out" button

  Scenario: Log in with incorrect email or password
    Given that I am on the login page
    And I fill in incorrect details
    When I click "Log in"
    Then I should be on login page and see error message "The email address or password you entered is incorrect"

  Scenario: Logging out
    Given that I have logged in
    And there's MeeGo 1.0, 1.1, and 1.2 releases
    And I'm viewing MeeGo 1.1 test results
    When I click "Log out"
    Then I should be on the home page and see "Log in" button
    And I should be viewing newest MeeGo release