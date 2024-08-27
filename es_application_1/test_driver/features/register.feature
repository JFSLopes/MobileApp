Feature: Account Registration

  Scenario: Successful account creation
    Given I am on the welcome screen of the sustainability app
    When I navigate to the "Sign Up" option
    And I enter a valid email address, username, and password
    And I click the "Sign Up" button
    Then I should be taken to a screen confirming my registration
    And I should receive a verification email at the provided email address
    And upon verifying my email, I should have access to all app features
