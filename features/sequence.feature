Feature: The sequence keyword
  In order to place contigs the scaffold
  A user can use the sequence keyword

  Scenario: A scaffold with a single sequence keyword
    Given the scaffold file has the sequences:
      | name | nucleotides |
      | seq  | ATGCC       |
    When creating a scaffolder object
    Then the scaffold should contain 1 sequence entries
    And the scaffold sequence should be ATGCC

  Scenario: A scaffold with a two sequence keywords
    Given the scaffold file has the sequences:
      | name | nucleotides |
      | seq1 | ATGCC       |
      | seq2 | ATGCC       |
    When creating a scaffolder object
    Then the scaffold should contain 2 sequence entries
    And the scaffold sequence should be ATGCCATGCC
