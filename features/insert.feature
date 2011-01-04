Feature: The insert keyword
  In order to place close gaps in the scaffold
  A user can use the insert keyword

  Scenario: A scaffold with a single insert keyword
    Given the scaffold file has the sequences:
      | name | nucleotides |
      | seq  | ATGCCGCGTAA |
    And the first scaffold sequence has the inserts:
      | name | nucleotides | open | close |
      | ins  | AAAA        | 4    | 6     |
    When creating a scaffolder object
    Then the scaffold should contain 1 sequence entries
    Then the scaffold should contain 1 insert entries
    And the scaffold sequence should be ATGAAAACGTAA
