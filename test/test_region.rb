require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder::Region do

    context "adding instance methods with attribute method" do

      setup do
        @attr = :some_attribute
      end

      should "create a single accessor attribute" do
        Scaffolder::Region.attribute @attr
        assert(Scaffolder::Region.instance_methods.include? @attr.to_s)
      end

      should "return nil until attribute value is stored" do
        Scaffolder::Region.attribute @attr
        region = Scaffolder::Region.new
        assert_equal(region.send(@attr),nil)
        region.send(@attr,5)
        assert_equal(region.send(@attr),5)
      end

      should "allow specification of default value" do
        Scaffolder::Region.attribute @attr, :default => 1
        region = Scaffolder::Region.new
        assert_equal(region.send(@attr),1)
        region.send(@attr,5)
        assert_equal(region.send(@attr),5)
      end

      should "allow specification of default value using a block" do
        Scaffolder::Region.attribute @attr, :default => lambda{|s| s.entry_type }
        region = Scaffolder::Region.new
        assert_equal(region.send(@attr),region.entry_type)
        region.send(@attr,5)
        assert_equal(region.send(@attr),5)
      end

    end

    context "passing the yaml hash to the generate method" do

      setup do
        Scaffolder::Region.attribute(:one)
        Scaffolder::Region.attribute(:two)
        @tags = {'one' => 1, 'two' => 2}
      end

      should "should call each tag in the hash as a method to store the value" do
        Scaffolder::Region.any_instance.expects(:one).with(1)
        Scaffolder::Region.any_instance.expects(:two).with(2)
        Scaffolder::Region.generate(@tags)
      end

      should "return an instantiated region object" do
        region = Scaffolder::Region.generate(@tags)
        assert_equal(region.one,1)
        assert_equal(region.two,2)
      end

      should "throw UnknownAttributeError for an unknown attribute" do
        assert_raise Scaffolder::Errors::UnknownAttributeError do
          Scaffolder::Region.generate({:three => 3})
        end
      end

    end

    context "attributes" do

      should_have_attribute Scaffolder::Region,
        :start, :stop, :reverse, :raw_sequence

      should "return the class name as the entry type" do
        Scaffolder::Region::NewRegion = Class.new(Scaffolder::Region)
        assert_equal(Scaffolder::Region::NewRegion.new.entry_type,:newregion)
      end

      should "return 1 as default value for start attribute" do
        sequence = Scaffolder::Region.new
        assert_equal(sequence.start,1)
      end

      should "return #raw_sequence length as default value for stop attribute" do
        length = 5
        sequence = Scaffolder::Region.new
        sequence.raw_sequence 'N' * length
        assert_equal(sequence.stop,length)
      end

    end

    context "generating the processed sequence" do

      [:sequence_hook, :raw_sequence].each do |method|

        context "using the #{method} method" do

          setup do
            # Test class to prevent interference with other tests
            @s = Class.new(Scaffolder::Region).new
            @s.class.send(:define_method,method,lambda{'ATGCCAGATAACTGACTAGCATG'})
          end

          should "return the sequence when no other options are passed" do
            assert_equal(@s.sequence,'ATGCCAGATAACTGACTAGCATG')
          end

          should "reverse complement sequence when passed the reverse option" do
            @s.reverse true
            assert_equal(@s.sequence, 'CATGCTAGTCAGTTATCTGGCAT')
          end

          should "create subsequence when passed sequence coordinates" do
            @s.start 5
            @s.stop 20
            assert_equal(@s.sequence,'CAGATAACTGACTAGC')
          end

          should "raise a CoordinateError when start is less than 1" do
            @s.start 0
            assert_raise(Scaffolder::Errors::CoordinateError){ @s.sequence }
          end

          should "raise a CoordinateError when stop is greater than sequence " do
            @s.stop 24
            assert_raise(Scaffolder::Errors::CoordinateError){ @s.sequence }
          end

          should "raise a CoordinateError when stop is greater than start " do
            @s.start 6
            @s.stop 5
            assert_raise(Scaffolder::Errors::CoordinateError){ @s.sequence }
          end

        end

      end

    end

    should "instantiate return corresponding region subclass when requested" do
      Scaffolder::Region::Type = Class.new
      assert_equal(Scaffolder::Region['type'],Scaffolder::Region::Type)
    end

  end
end
