Feature: Password Reset

  Scenario: User resets password
    Given I am on the login page of the application
    And I have forgotten my password
    When I click on the "Forgot Password" link
    Then I should be redirected to the password reset page
    And prompted to enter my email address
    When I enter my email address associated with my account
    And click on the "Reset Password" button
    Then I should receive an email with instructions to reset my password
    And the email should contain a unique password reset link
    When I click on the password reset link in the email
    Then I should be directed to a page where I can enter a new password
    And confirm the new password
    When I enter and confirm the new password
    And click on the "Submit" button
    Then I should receive confirmation that my password has been successfully reset
    And I should be redirected to the login page
    When I log in with my new password
    Then I should be granted access to my account
    And I should retain my preferences and data
