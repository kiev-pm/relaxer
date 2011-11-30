Feature: Share RegExp by URL
    As a social animal
    I want to share my regexps by url
    In order to share my experience with friends on Twitter, Facebook and so on

Scenario: Encode the Regexp  and String settings in the Browser URL
    Given I am on the page Relaxer.Matches
    When I set Regexp to “foo (#&%)”
      And I set String to “foo #&%?”
      And I click on the button “Execute regexp”
    Then I should see new generated URL in the Web Browser
    When I press F5 to update the page
    Then I can see Regexp is set to “foo (#&%)”
    And I can see String is set to “foo #&%?”

