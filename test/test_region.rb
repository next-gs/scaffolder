require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder::Region do
    should "be created from parameters" do
      region = Scaffolder::Region.new(:unresolved,'NNNN')
      assert_equal(region.entry_type,:unresolved)
      assert_equal(region.sequence,'NNNN')
    end
  end
end
