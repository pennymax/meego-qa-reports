Feature: Logging in
  In order to submit test reports to the system
  MeeGo test engineers
  Want to be able to log in to MeeGoQA

  Scenario: Log in with correct email address and password
    Given I have one user "John Longbottom" with email "tester@meego.com" and password "testing4ever"
    And I'm not logged in

    Given there exists a report for "1.1/Handset/Sanity/N900"

    When I go to the front page
    #And there's MeeGo 1.0, 1.1 and 1.2 releases
    And I view the report "1.1/Handset/Sanity/N900"

    When I log in with email "tester@meego.com" and password "testing4ever"
    Then I should return to report "1.1/Handset/Sanity/N900" and see "John Longbottom" and a "Sign out" button

  Scenario: Log in with incorrect email
    Given there is no user with email "jamesbond@mi6.co.uk"

    When I go to the front page
    And I log in with email "jamesbond@mi6.co.uk" and password "octopussy"

    Then I should be on the login page
    And I should see "The email address or password you entered is incorrect"

  Scenario: Log in with correct email but incorrect password
    Given I have one user "Timothy Dalton" with email "jamesbond@mi6.co.uk" and password "pussygalore"

    When I go to the front page
    And I log in with email "jamesbond@mi6.co.uk" and password "octopussy"

    Then I should be on the login page
    And I should see "The email address or password you entered is incorrect"

  Scenario: Logging out
    Given I have one user "Timothy Dalton" with email "jamesbond@mi6.co.uk" and password "octopussy"
    And there exists a report for "1.1/Handset/Sanity/N900"

    When I log in with email "jamesbond@mi6.co.uk" and password "octopussy"
    And I view the report "1.1/Handset/Sanity/N900"

    When I follow "Sign out" within "#session"
    Then I should be on the front page
    And I should see "Sign In" within "#session"
    
#    And there's MeeGo 1.0, 1.1, and 1.2 releases
#    And I'm viewing MeeGo 1.1 test results
#    When I click "Log out"
#    Then I should be on the home page and see "Log in" button
#    And I should be viewing newest MeeGo release
