require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder do
    
    setup do
      Scaffolder::Region::Mock = Class.new(Scaffolder::Region)
      @sequence = nil
      Bio::FlatFile.expects(:auto).with(@sequence).returns({})
      @data = [{'mock' => Hash.new}]
    end

    context 'when instantiated' do

      should "fetch correct region class type" do
        Scaffolder::Region.expects(:'[]').with('mock').returns(Scaffolder::Region::Mock)
        Scaffolder.new(@data,@sequence)
      end

      should "pass data to region object" do
        Scaffolder::Region::Mock.expects(:generate).with(@data.first['mock'])
        Scaffolder.new(@data,@sequence)
      end

    end

  end
end
