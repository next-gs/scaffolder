require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder do

    Scaffolder::Region::Mock = Class.new(Scaffolder::Region)

    setup do
      @sequence = nil
      @data = [{'mock' => Hash.new}]
    end

    context 'parsing a scaffold file' do

      setup do
        Bio::FlatFile.stubs(:auto).with(@sequence).returns({})
      end

      should "fetch correct region class type" do
        Scaffolder::Region.expects(:'[]').with('mock').returns(Scaffolder::Region::Mock)
        Scaffolder.new(@data,@sequence)
      end

      should "pass data to region object" do
        Scaffolder::Region::Mock.expects(:generate).with(@data.first['mock'])
        Scaffolder.new(@data,@sequence)
      end

    end

    context 'parsing a scaffold file with a source keyword' do

      setup do
        Bio::FlatFile.stubs(:auto).with(@sequence).returns([
          stub(:definition => 'seq1', :seq => 'ATGC')])
      end

      should "should also pass raw_sequence from flat file" do
        @data.first['mock']['source'] = 'seq1'
        Scaffolder::Region::Mock.any_instance.expects(:source).with('seq1')
        Scaffolder::Region::Mock.any_instance.expects(:raw_sequence).with('ATGC')
        Scaffolder.new(@data,@sequence)
      end

    end

    context 'updating each data hash with raw_sequence attributes' do

      setup do
        @seqs = {'seq1' => 'AAA'}
        @expected = {'source' => 'seq1', 'raw_sequence' => @seqs['seq1']}
      end

      should "do nothing when no source keyword" do
        test = {'something' => 'nothing'}
        assert_equal(test,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to simple hash" do
        test = {'source' => 'seq1'}
        assert_equal(@expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to a nested hash" do
        test     = {'something' => {'source' => 'seq1'}}
        expected = {'something' => @expected}
        assert_equal(expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to a twice nested hash" do
        test     = {'something' => {'other' => {'source' => 'seq1'}}}
        expected = {'something' => {'other' => @expected}}
        assert_equal(expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to simple hash inside an array" do
        test     = [{'source' => 'seq1'}]
        expected = [@expected]
        assert_equal(expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to a nested hash inside an array" do
        test     = {'something' => [{'source' => 'seq1'}]}
        expected = {'something' => [@expected]}
        assert_equal(expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to two nested hashes inside an array" do
        test     = {'something' => [{'source' => 'seq1'},{'source' => 'seq1'}]}
        expected = {'something' => [@expected,@expected]}
        assert_equal(expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to a hash inside a hash inside an array" do
        test     = {'something' => [{'else' => {'source' => 'seq1'}}]}
        expected = {'something' => [{'else' => @expected}]}
        assert_equal(expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "add raw_sequence to a twice nested (hash inside an array)" do
        test     = {'something' => [{'else' => [{'source' => 'seq1'}]}]}
        expected = {'something' => [{'else' => [@expected]}]}
        assert_equal(expected,Scaffolder.update_with_sequence(test,@seqs))
      end

      should "throw an UnknownSequenceError when no matching sequence" do
        test = {'source' => 'non_existent_sequence'}
        assert_raise(Scaffolder::Errors::UnknownSequenceError) do
          Scaffolder.update_with_sequence(test,@seqs)
        end
      end

    end

  end
end
