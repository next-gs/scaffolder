require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder do

    setup do
      @order    = File.join(File.dirname(__FILE__),'data','scaffold_order.yml')
      @sequence = File.join(File.dirname(__FILE__),'data','sequences.fna')
      @scaffold_hash = YAML.load(File.new(@order))
    end

    context "reading in a scaffolding file" do

      should "not throw an error" do
        begin
          Scaffolder::Scaffold.new(@order,@sequence)
        rescue
          flunk "Error reading data file"
        end
      end

      should "show the expected number of regions" do
        regions = Scaffolder::Scaffold.new(@order,@sequence)
        assert_equal(regions.length,3)
      end

    end

    context "parsing a correct sequence object" do

      setup do
        @scaffolds = Scaffolder::Scaffold.new(@order,@sequence)
      end

      should "show the correct start position based on sequence" do
        assert_equal(@scaffolds.first.start, 1)
      end

      should "show the correct end position based on sequence" do
        assert_equal(@scaffolds.first.end, 23)
      end

      should "show the correct sequence name" do
        assert_equal(@scaffolds.first.name, 'sequence1')
      end

      should "show the correct sequence length based on sequence" do
        assert_equal(@scaffolds.first.length, 23)
      end

      should "show the correct sequence for a sequence tag" do
        assert_equal(@scaffolds.first.sequence, 'ATGCCAGATAACTGACTAGCATG')
      end

      should "show the correct start position based on scaffold file" do
        assert_equal(@scaffolds[1].start, 5)
      end

      should "show the correct end position based on scaffold file" do
        assert_equal(@scaffolds[1].end, 25)
      end

      should "show the correct sequence length based on scaffold file" do
        assert_equal(@scaffolds[1].length, 21)
      end

      should "show the correct sequence based on scaffold file" do
        assert_equal(@scaffolds[1].sequence, 'CTGACTAGCTGAAGGATTCCA')
      end

      should "show the correct region type" do
        assert_equal(@scaffolds.first.type, 'sequence')
        assert_equal(@scaffolds.last.type, 'unresolved')
      end

      should "show the correct start position for unresolved region" do
        assert_equal(@scaffolds.last.start, 1)
      end

      should "show the correct end position for unresolved region" do
        assert_equal(@scaffolds.last.end, 10)
      end

      should "show the correct sequence for an unresolved tag" do
        assert_equal(@scaffolds.last.sequence, 'N'*10)
      end

      should "show the correct sequence length for unresolved tag" do
        assert_equal(@scaffolds.last.length, 10)
      end
    end

    context "parsing an unknown tag in the scaffold file" do
      setup{ @scaffold_hash << {'non_standard_tag' => []} }
      should_throw_argument_error{[ @scaffold_hash, @sequence ]}
    end

    context "start position is outside sequence" do
      setup{ @scaffold_hash.first['sequence'].update({'start' => 0}) }
      should_throw_argument_error{[ @scaffold_hash, @sequence ]}
    end

    context "end position is outside sequence" do
      setup{ @scaffold_hash.first['sequence'].update({'end' => 35}) }
      should_throw_argument_error{[ @scaffold_hash, @sequence ]}
    end

    context "region in file does not match sequence" do
      setup{ @scaffold_hash << {'sequence' => {'source' => 'sequence3'}} }
      should_throw_argument_error{[ @scaffold_hash, @sequence ]}
    end

  end
end
