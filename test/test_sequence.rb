require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder::Sequence do

    setup do
      @options = { :name => "sequence1",
        :sequence => 'ATGCCAGATAACTGACTAGCATG' }
    end

    context "processing a simple sequence tag" do

      should "create sequence object" do
        sequence = Scaffolder::Sequence.new @options
        assert_equal(sequence.entry_type,:sequence)
        assert_equal(sequence.start,1)
        assert_equal(sequence.end,23)
        assert_equal(sequence.name,'sequence1')
        assert_equal(sequence.sequence,'ATGCCAGATAACTGACTAGCATG')
        assert_equal(sequence.raw_sequence,'ATGCCAGATAACTGACTAGCATG')
      end

      should "reverse sequence when passed the reverse option" do
        sequence = Scaffolder::Sequence.new @options.merge(:reverse => true)
        assert_equal(sequence.sequence,'CATGCTAGTCAGTTATCTGGCAT')
        assert_equal(sequence.raw_sequence,'ATGCCAGATAACTGACTAGCATG')
      end

      should "create subsequence object when passed sequence coordinates" do
        sequence = Scaffolder::Sequence.new @options.merge(:start => 5,:end => 20)
        assert_equal(sequence.start,5)
        assert_equal(sequence.end,20)
        assert_equal(sequence.sequence,'CAGATAACTGACTAGC')
      end

      should "throw an error when the start position is outside the sequence length" do
        begin
          Scaffolder::Sequence.new @options.merge(:start => 0)
          flunk "Should throw an argument error"
        rescue ArgumentError
        end
      end

      should "throw an error when the end position is outside the sequence length" do
        begin
          Scaffolder::Sequence.new @options.merge(:end => 24)
          flunk "Should throw an argument error"
        rescue ArgumentError
        end
      end

      should "throw an error when the start is greater than the end" do
        begin
          Scaffolder::Sequence.new @options.merge(:end => 5,:start => 10)
          flunk "Should throw an argument error"
        rescue ArgumentError
        end
      end

    end

    context "processing a sequence tag with inserts" do

      setup do
        @insert = {:start => 5, :stop => 10, :sequence => 'GGTAGTA'}
        @sequence = Scaffolder::Sequence.new @options
      end

      should "raise when the insert start is after the sequence end" do
        @insert.update(:start => 24,:stop => nil)
        assert_raise(ArgumentError) do
          @sequence.add_inserts([Scaffolder::Insert.new @insert])
        end
      end

      should "raise when the insert stop is before the sequence start" do
        @insert.update(:start => -5,:stop => 0)
        assert_raise(ArgumentError) do
          @sequence.add_inserts([Scaffolder::Insert.new @insert])
        end
      end

      should "raise when insert start is greater than end" do
        @insert.update(:start => 11)
        assert_raise(ArgumentError) do
          @sequence.add_inserts([Scaffolder::Insert.new @insert])
        end
      end

      should "update the sequence" do
        @sequence.add_inserts([Scaffolder::Insert.new @insert])
        assert_equal(@sequence.sequence,'ATGCGGTAGTAACTGACTAGCATG')
        assert_equal(@sequence.end,24)
        assert_equal(@sequence.raw_sequence,'ATGCCAGATAACTGACTAGCATG')
      end

      should "return added insert as an attribute" do
        inserts = [Scaffolder::Insert.new @insert]
        @sequence.add_inserts(inserts)
        assert_equal(@sequence.inserts,inserts)
      end

      should "return empty array when no inserts and inserts method called" do
        assert_equal(@sequence.inserts,[])
      end

      should "update the sequence when reversed" do
        @sequence = Scaffolder::Sequence.new @options.update(:reverse => true)
        @sequence.add_inserts([Scaffolder::Insert.new @insert])
        assert_equal(@sequence.sequence,"CATGCTAGTCAGTTACTACCGCAT")
        assert_equal(@sequence.raw_sequence,'ATGCCAGATAACTGACTAGCATG')
      end

      should "update the sequence with two inserts" do
        @sequence.add_inserts([Scaffolder::Insert.new(@insert),
          Scaffolder::Insert.new(@insert.update(:start => 12, :stop => 15))])
        assert_equal(@sequence.sequence,"ATGCGGTAGTAAGGTAGTACTAGCATG")
        assert_equal(@sequence.end,27)
        assert_equal(@sequence.raw_sequence,'ATGCCAGATAACTGACTAGCATG')
      end
    end

  end
end
