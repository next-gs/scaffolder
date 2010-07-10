require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder do

    setup do
      @sequence = File.join(File.dirname(__FILE__),'data','sequences.fna')
    end

    context "reading in a scaffolding file" do

      setup do
        @assembly = [
          {"sequence" =>
            { "source" => "sequence1" }
          }
        ]
      end

      should "not throw an error" do
        begin
          Scaffolder::Scaffold.new(temporary_scaffold_file(@assembly),@sequence)
        rescue
          flunk "Error reading data file"
        end
      end

    end

    context "parsing a simple single sequence assembly" do

      setup do
        @assembly = [
          {"sequence" =>
            { "source" => "sequence1" }
          }
        ]
      end

      should_set_region(:start   ,  1)         {[ @assembly, @sequence ]}
      should_set_region(:end     , 23)         {[ @assembly, @sequence ]}
      should_set_region(:length  , 23)         {[ @assembly, @sequence ]}
      should_set_region(:name    , 'sequence1'){[ @assembly, @sequence ]}
      should_set_region(:sequence, 'ATGCCAGATAACTGACTAGCATG'){[ @assembly, @sequence ]}

    end

    context "parsing an assembly with a reversed region" do

      setup do
        @assembly = [
          {"sequence" =>
            { "source" => "sequence1",
              "reverse" => true        }
          }
        ]
      end

      should_set_region(:start   ,  1)         {[ @assembly, @sequence ]}
      should_set_region(:end     , 23)         {[ @assembly, @sequence ]}
      should_set_region(:length  , 23)         {[ @assembly, @sequence ]}
      should_set_region(:name    , 'sequence1'){[ @assembly, @sequence ]}
      should_set_region(:sequence, 'TACGGTCTATTGACTGATCGTAC'){[ @assembly, @sequence ]}

    end

    context "parsing an assembly with specified sequence start and end" do

      setup do
        @assembly = [
          {"sequence"=>
            { "end"    => 25,
              "start"  => 5,
              "source" => "sequence2"
            }
          }
        ]
      end

      should_set_region(:start   ,  5)         {[ @assembly, @sequence ]}
      should_set_region(:end     , 25)         {[ @assembly, @sequence ]}
      should_set_region(:length  , 21)         {[ @assembly, @sequence ]}
      should_set_region(:name    , 'sequence2'){[ @assembly, @sequence ]}
      should_set_region(:type    , 'sequence'){[ @assembly, @sequence ]}
      should_set_region(:sequence, 'CTGACTAGCTGAAGGATTCCA'){[ @assembly, @sequence ]}
    end

    context "parsing an assembly with an unresolved region" do

      setup do
        @assembly = [
          {"unresolved" =>
            { "length" => 10 }
          }
        ]
      end

      should_set_region(:start   ,  1)          {[ @assembly, @sequence ]}
      should_set_region(:end     , 10)          {[ @assembly, @sequence ]}
      should_set_region(:length  , 10)          {[ @assembly, @sequence ]}
      should_set_region(:name    , 'unresolved'){[ @assembly, @sequence ]}
      should_set_region(:type    , 'unresolved'){[ @assembly, @sequence ]}
      should_set_region(:sequence, 'N'*10)      {[ @assembly, @sequence ]}
    end

    context "parsing an assembly with an unknown tag" do
      setup{ @assembly = [{'non_standard_tag' => []}] }
      should_throw_argument_error{[ @assembly, @sequence ]}
    end

    context "parsing an assembly where the start position is outside sequence" do
      setup do
        @assembly = [
          {"sequence"=>
            { "start"    => 0,
              "source" => "sequence1"
            }
          }
        ]
      end
      should_throw_argument_error{[ @assembly, @sequence ]}
    end

    context "parsing an assembly where the end position is outside sequence" do
      setup do
        @assembly = [
          {"sequence"=>
            { "end"    => 35,
              "source" => "sequence1"
            }
          }
        ]
      end
      should_throw_argument_error{[ @assembly, @sequence ]}
    end

    context "parsing an assmbly where a region does have a matching sequence" do
      setup{ @assembly = [{'sequence' => {'source' => 'sequence3'}}] }
      should_throw_argument_error{[ @assembly, @sequence ]}
    end

  end
end
