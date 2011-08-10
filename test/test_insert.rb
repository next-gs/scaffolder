require 'helper'

class TestInsert < Test::Unit::TestCase
  context Scaffolder::Region::Insert do

    context "attributes" do

      should_have_attribute Scaffolder::Region::Insert, :source, :open, :close

      setup do
        @length = 15
        @insert = Scaffolder::Region::Insert.new
        @insert.raw_sequence('N' * @length)
      end

      should "return open plus sequence length as default close" do
        @insert.open  5
        assert_equal(@insert.close,@insert.open + @length - 1)
      end

      should "return close minus sequence length as default open" do
        @insert.close 20
        assert_equal(@insert.open,@insert.close - @length - 1)
      end

      should "include the insert position" do
        @insert.open  5
        @insert.close 10
        assert_equal(@insert.position,4..9)
      end

      should "throw an error when neither open or close are provided" do
        assert_raise(Scaffolder::Errors::CoordinateError){ @insert.position }
      end

    end

    context "#size_diff" do

      setup do
        @insert = Scaffolder::Region::Insert.new
        @insert.open  3
        @insert.close 5
      end

      should "return a negative diff for a sequence smaller than insert site" do
        @insert.raw_sequence 'TT'
        assert_equal(@insert.size_diff,-1)
      end

      should "return 0 for a sequence equal to the insert site" do
        @insert.raw_sequence 'TTT'
        assert_equal(@insert.size_diff,0)
      end

      should "return a positive diff for a sequence larger than insert site" do
        @insert.raw_sequence 'TTTT'
        assert_equal(@insert.size_diff,1)
      end

    end

    should "be comparable by close position" do
      a = Scaffolder::Region::Insert.new
      a.close 1

      b = a.clone
      b.close 2

      c = b.clone
      c.close 3

      assert_equal([c,a,b].sort, [a,b,c])
    end

  end
end
