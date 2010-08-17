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

    context "parsing an assembly with sequence coordinates" do

      context "correctly specified" do

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

      context "where the start position is outside the sequence length" do
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

      context "where the start is greater than the end" do
        setup do
          @assembly = [
            {"sequence"=>
              { "start"  => 5,
                "end"    => 4,
                "source" => "sequence1"
              }
            }
          ]
        end
        should_throw_argument_error{[ @assembly, @sequence ]}
      end

      context "where the end position is outside the sequence length" do
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

    end

    context "parsing an assembly where a region doesn't have a matching sequence" do
      setup{ @assembly = [{'sequence' => {'source' => 'sequence3'}}] }
      should_throw_argument_error{[ @assembly, @sequence ]}
    end

    context "parsing an assembly with sequence inserts" do

      setup do
        @assembly = [
          {"sequence" =>
            { "source"  => "sequence2",
              "inserts" => [
                { "source" => "insert1",
                  "start"  => 5,
                  "end"    => 10
                }
            ]
            }
          }
        ]
      end

      context "correctly specified with start and end" do
        should_set_region(:start   ,  1)         {[ @assembly, @sequence ]}
        should_set_region(:end     , 31)         {[ @assembly, @sequence ]}
        should_set_region(:length  , 31)         {[ @assembly, @sequence ]}
        should_set_region(:name    , 'sequence2'){[ @assembly, @sequence ]}
        should_set_region(:type    , 'sequence'){[ @assembly, @sequence ]}
        should_set_region(:sequence, 'AATGGGTAGTAAGCTGAAGGATTCCATATAC'){[@assembly,@sequence]}
      end

      context "correctly specified with start and end with reverse sequence" do
        setup do
          @assembly.first['sequence']['reverse'] = true
        end

        should_set_region(:start   ,  1)         {[ @assembly, @sequence ]}
        should_set_region(:end     , 31)         {[ @assembly, @sequence ]}
        should_set_region(:length  , 31)         {[ @assembly, @sequence ]}
        should_set_region(:name    , 'sequence2'){[ @assembly, @sequence ]}
        should_set_region(:type    , 'sequence'){[ @assembly, @sequence ]}
        should_set_region(:sequence, 'TTACCCATCATTCGACTTCCTAAGGTATATG'){[ @assembly, @sequence ]}
      end

      context "where the insert does not have a matching sequence" do
        setup do
          @assembly.first['sequence']['inserts'].first['source'] = "missing"
        end
        should_throw_argument_error{[ @assembly, @sequence ]}
      end

      context "where the insert start is after the sequence end" do
        setup do
          @assembly.first['sequence']['inserts'].first['start'] = 40
        end
        should_throw_argument_error{[ @assembly, @sequence ]}
      end

      context "where the insert end is before the sequence start" do
        setup do
          @assembly.first['sequence']['inserts'].first['end'] = 0
        end
        should_throw_argument_error{[ @assembly, @sequence ]}
      end

      context "two correctly specified inserts with start and end" do
        setup do
          @assembly.first['sequence']['inserts'] = [
          { "source" => "insert1",
            "start"  => 5,
            "end"    => 8
          },
          { "source" => "insert1",
            "start"  => 15,
            "end"    => 17
          }]
        end
        should_set_region(:start   ,  1)         {[ @assembly, @sequence ]}
        should_set_region(:end     , 37)         {[ @assembly, @sequence ]}
        should_set_region(:length  , 37)         {[ @assembly, @sequence ]}
        should_set_region(:name    , 'sequence2'){[ @assembly, @sequence ]}
        should_set_region(:type    , 'sequence'){[ @assembly, @sequence ]}
        should_set_region(:sequence, 'AATGGGTAGTACTAGCTGGTAGTAGGATTCCATATAC'){[@assembly,@sequence]}

      end

      context "correctly specified with start and end with subsequence" do; end

    end

  end
end
