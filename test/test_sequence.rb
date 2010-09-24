require 'helper'

class TestSequence < Test::Unit::TestCase
  context Scaffolder::Region::Sequence do

    context "attributes" do

      should_have_method_attribute Scaffolder::Region::Sequence

      should_have_attribute Scaffolder::Region::Sequence, :source, :inserts

      should "return empty array as inserts attribute default" do
        sequence = Scaffolder::Region::Sequence.new
        assert_equal(sequence.inserts,Array.new)
      end

    end

    context "with inserts added" do

      setup do
        @sequence = Scaffolder::Region::Sequence.new
        @sequence.raw_sequence 'ATGCCAGATAACTGACTAGCATG'

        @insert = Scaffolder::Region::Insert.new
        @insert.raw_sequence 'GGTAGTA'
        @insert.open  5
        @insert.close 10
      end

      should "raise when the insert open is after the sequence stop" do
        @insert.open 24
        @insert.close 25
        @sequence.inserts [@insert]
        assert_raise(Scaffolder::Errors::CoordinateError){ @sequence.sequence }
      end

      should "raise when the insert close is before the sequence start" do
        @insert.open -5
        @insert.close 0
        @sequence.inserts [@insert]
        assert_raise(Scaffolder::Errors::CoordinateError){ @sequence.sequence }
      end

      should "raise when the insert open is greater than the insert close" do
        @insert.open 11
        @sequence.inserts [@insert]
        assert_raise(Scaffolder::Errors::CoordinateError){ @sequence.sequence }
      end

      should "update the sequence with a simple insert" do
        @sequence.inserts [@insert]
        assert_equal(@sequence.sequence,'ATGCGGTAGTAACTGACTAGCATG')
      end

      should "update the sequence stop position after adding a simple insert" do
        @sequence.inserts [@insert]
        assert_equal(@sequence.stop,24)
      end

      should "update sequence with inserts in reverse order" do
        insert_two = @insert.clone
        insert_two.open 12
        insert_two.close 15
        @sequence.inserts [@insert,insert_two]
        assert_equal(@sequence.sequence,"ATGCGGTAGTAAGGTAGTACTAGCATG")
      end
    end

  end
end
