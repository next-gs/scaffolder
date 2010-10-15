require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder do
    
    Scaffolder::Region::Mock = Class.new(Scaffolder::Region)

    setup do
      @sequence = nil
      @data = [{'mock' => Hash.new}]
    end

    context 'when instantiated' do

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

    context 'when instantiated with source tag' do

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

  end
end
