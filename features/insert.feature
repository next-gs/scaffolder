Feature: The insert keyword
  In order to place close gaps in the scaffold
  A user can use the insert keyword

  Scenario: A scaffold with a single insert keyword
    Given a file named "sequence.fna" with:
      """
      >seq
      TTTTTTTTT
      >insert
      AAA
      """
    Given a file named "scaffold.yml" with:
      """
      ---
        -
          sequence:
            source: "seq"
            inserts:
            -
              source: "insert"
              open: 4
              close: 6
      """
    When creating a scaffold with the files "scaffold.yml" and "sequence.fna"
    Then the scaffold should contain 1 sequence entries
    Then the scaffold should contain 1 insert entries
    And the scaffold sequence should be TTTAAATTT
