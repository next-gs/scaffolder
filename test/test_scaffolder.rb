require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder do

    setup do
      @order    = File.join(File.dirname(__FILE__),'data','scaffold_order.yml')
      @sequence = File.join(File.dirname(__FILE__),'data','sequences.fna')
    end

    context "reading in a scaffolding file" do

      should "not throw an error" do
        begin
          Scaffolder.read(@order,@sequence)
        rescue
          flunk "Error reading data file"
        end
      end

      should "show the expected number of regions" do
        regions = Scaffolder.read(@order,@sequence)
        assert(regions.length,2)
      end

    end

    context "parsing a correct sequence object" do

      setup do
        @scaffolds = Scaffolder.read(@order,@sequence)
      end

      should "show the correct start position based on sequence" do
        assert_equal(@scaffolds.first.start, 1)
      end

      should "show the correct end position based on sequence" do
        assert_equal(@scaffolds.first.end, 23)
      end

      should "show the correct start position based on scaffold file" do
        assert_equal(@scaffolds[1].start, 5)
      end

      should "show the correct end position based on scaffold file" do
        assert_equal(@scaffolds[1].end, 25)
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
    end

    context "parsing an incorrect scaffold file" do

      should "throw an error when start position is outside sequence" do
        err = YAML.load(File.read(@order))
        err.first['sequence'].update({'start' => -1})
        begin
          Scaffolder.read(temporary_scaffold_file(err),@sequence)
          flunk "Should throw an error"
        rescue ArgumentError
        end
      end

      should "throw an error if file end position is outside sequence" do
        err = YAML.load(File.read(@order))
        err.first['sequence'].update({'end' => 35})
        begin
          Scaffolder.read(temporary_scaffold_file(err),@sequence)
          flunk "Should throw an error"
        rescue ArgumentError
        end
      end

      should "throw an error if scaffold in file does not match sequence" do
        err = YAML.load(File.read(@order))
        err << {'sequence' => {'source' => 'sequence3'}}
        begin
          Scaffolder.read(temporary_scaffold_file(err),@sequence)
          flunk "Should throw an error"
        rescue ArgumentError
        end
      end

    end

  end
end
