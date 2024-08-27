Feature: Set a distance range for activity notifications

    Scenario: User sets a preferred distance range for local events:

        Given I am a logged-in user on the sustainability app
        When I navigate to the "Choose a location" feature
        And I move the distance slider to set my preferred range to "16 km"
        And I opt to "Use my current location"
        Then my location should be set to my current GPS coordinates
