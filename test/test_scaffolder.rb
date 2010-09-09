require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder do
    
    setup do
      @sequence = File.join(File.dirname(__FILE__),'data','sequences.fna')
        @assembly = [ {"sequence" => { "source" => "sequence1" } } ]
        @expect = {:name => 'sequence1', :start => nil, :end => nil,
          :sequence => 'ATGCCAGATAACTGACTAGCATG', :reverse => nil}
    end

    context "when parsing a sequence tag" do

      should "create sequence" do
        mock(Scaffolder::Sequence).new(@expect)
        Scaffolder.new @assembly, @sequence
      end

      should "create sequence with coordinates" do
        @assembly.first['sequence'].update('start' => 2, 'end' => 5)
        mock(Scaffolder::Sequence).new(@expect.update({:start => 2, :end => 5 }))
        Scaffolder.new @assembly, @sequence
      end

      should "create sequence with reverse" do
        @assembly.first['sequence'].update('reverse' => true)
        mock(Scaffolder::Sequence).new(@expect.update({:reverse => true }))
        Scaffolder.new @assembly, @sequence
      end

      should "throw an error when source doesn't have a matching sequence" do
        @assembly.first['sequence'].update('source' => 'sequence3')
        assert_raise(ArgumentError){ Scaffolder.new @assembly, @sequence }
      end
    end

    context "parsing an assembly with sequence inserts" do

      setup do
        @assembly.first['sequence'].update({"inserts" => [{
          "source" => "insert1", "start" => 5, "stop" => 10, "reverse" => true
        }]})
      end

      should "pass inserts to sequence object" do
        params = {:start => 5, :stop => 10,
          :sequence => 'GGTAGTA', :reverse => true}

        insert = Scaffolder::Insert.new(params)

        mock.instance_of(Scaffolder::Sequence).add_inserts([insert])
        mock(Scaffolder::Insert).new(params){insert}

        Scaffolder.new @assembly, @sequence
      end

      should "throw and error when insert does not have a matching sequence" do
        @assembly.first['sequence']['inserts'].first.update({
          "source" => "missing"})
        assert_raise(ArgumentError){ Scaffolder.new @assembly, @sequence }
      end

    end

    context "when parsing an assembly with an unresolved region" do

      setup{ @assembly = [ {"unresolved" => { "length" => 5 } } ] }

      should 'create an unresolved region' do
        mock(Scaffolder::Region).new(:unresolved,'N'*5)
        Scaffolder.new @assembly, @sequence
      end

    end

    context "when parsing an unknown tag" do
      setup{ @assembly = [{'non_standard_tag' => []}] }
      should "throw an argument error" do
        assert_raise(ArgumentError){ Scaffolder.new @assembly, @sequence }
      end
    end

  end
end
