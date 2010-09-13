require 'helper'

class TestInsert < Test::Unit::TestCase
  context Scaffolder::Insert do

    setup do
      @options = {
        :start    => 5,
        :stop     => 10,
        :sequence => "ATGCGGGC"
      }
    end

    should "correctly store the passed options" do
      i = Scaffolder::Insert.new @options
      assert_equal(i.start, @options[:start])
      assert_equal(i.stop, @options[:stop])
      assert_equal(i.sequence, @options[:sequence])
    end

    should "reverse the sequence when passed the reverse tag" do
      i = Scaffolder::Insert.new @options.merge(:reverse => true)
      rev = Bio::Sequence::NA.new(@options[:sequence]).reverse_complement
      assert_equal(i.sequence, rev.upcase)
    end

    should "correctly generate the position" do
      i = Scaffolder::Insert.new @options
      assert_equal(i.position, (@options[:start]-1)..(@options[:stop]-1))
    end

    should "estimate the sequence end position" do
      @options.delete(:stop)
      i = Scaffolder::Insert.new @options
      assert_equal(i.stop, @options[:start] + @options[:sequence].length - 1)
    end

    should "estimate the sequence start position" do
      @options.delete(:start)
      i = Scaffolder::Insert.new @options
      assert_equal(i.start, @options[:stop] - @options[:sequence].length - 1)
    end

    should "throw error when neither start or stop are provided" do
      @options.delete(:start)
      @options.delete(:stop)
      assert_raise ArgumentError do
        Scaffolder::Insert.new @options
      end
    end

    should "be comparable by end position" do
      a = Scaffolder::Insert.new @options
      b = Scaffolder::Insert.new @options.merge(:stop => @options[:stop] + 1)
      c = Scaffolder::Insert.new @options.merge(:stop => @options[:stop] + 2)
      assert_equal([c,a,b].sort, [a,b,c])
    end

  end
end
