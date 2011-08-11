Feature: The sequence keyword
  In order to place contigs the scaffold
  A user can use the sequence keyword

  Scenario: A scaffold with a single sequence keyword
    Given a file named "sequence.fna" with:
      """
      >seq
      TTTTT
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
      """
    When creating a scaffold with the files "scaffold.yml" and "sequence.fna"
    Then the scaffold should contain 1 sequence entries
    And the scaffold sequence should be TTTTT

  Scenario: A scaffold with a two sequence keywords
    Given a file named "sequence.fna" with:
      """
      >seq1
      TTT
      >seq2
      AAA
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq1"
        -
          sequence:
            source: "seq2"
      """
    When creating a scaffold with the files "scaffold.yml" and "sequence.fna"
    Then the scaffold should contain 2 sequence entries
    And the scaffold sequence should be TTTAAA
