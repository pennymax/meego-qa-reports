Feature: Signing up as a new user
  In order to gain access to submit test reports to MeeGoQA
  New MeeGo test engineers
  Want to be able to sign up for an account to MeeGoQA

  Scenario: Signing up with unique email address
    Given there is no user with email "jamesbond@mi6.co.uk"

    When I sign up as "Timothy Dalton" with email "jamesbond@mi6.co.uk" and password "pussygalore"

    Then I should be on the front page
    And I should see "Sign out" within "#session"
    And there should be a user "Timothy Dalton" with email "jamesbond@mi6.co.uk"

    When I follow "Sign out" within "#session"
    And I log in with email "jamesbond@mi6.co.uk" and password "pussygalore"

    Then I should see "Sign out" within "#session"

  Scenario: Signing up with an already registered email address
    Given I have one user "Timothy Dalton" with email "jamesbond@mi6.co.uk" and password "pussygalore"

    When I sign up as "Austin Powers" with email "jamesbond@mi6.co.uk" and password "shagyoulater"

    Then I should see "Email has already been taken" within "#error"
    And I should see "Sign In" within "#session"

  Scenario: Signing up without a given name, invalid email and not matching password confirmation
    Given there is no user with email "jamesbond@mi6.co.uk"

    When I sign up as "" with email "james bond @ mi6@co.uk" and password "pussygalore" and password confirmation "somethingelsepussy"

    Then I should see "Name can't be blank"
    And I should see "Email is invalid"
    And I should see "Password doesn't match confirmation"
