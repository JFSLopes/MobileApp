Feature: Login

  Scenario: User successfully logs in to the sustainability app
    Given I am on the login page of the sustainability app
    When I enter my valid username and password
    And I click on the "Login" button
    Then I should be redirected to the homepage of the sustainability app

  Scenario: User fails to log in with incorrect credentials
    Given I am on the login page of the sustainability app
    When I enter an incorrect username and/or password
    And I click on the "Login" button
    Then I should see an error message that says "Invalid username or password"

  Scenario: User tries to log in without entering any credentials
    Given I am on the login page of the sustainability app
    When I do not enter a username or a password
    And I click on the "Login" button
    Then I should see an error message that says "Username and password are required"
