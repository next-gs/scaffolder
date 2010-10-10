require 'helper'

class TestScaffolder < Test::Unit::TestCase
  context Scaffolder::Region::Unresolved do

    should_have_method_attribute Scaffolder::Region::Unresolved
    should_have_attribute Scaffolder::Region::Unresolved, :length

    should "return unresolved sequence when given length" do
      length = 5
      unresolved = Scaffolder::Region::Unresolved.new
      unresolved.length length
      assert_equal(unresolved.sequence,'N' * 5)
    end

    should "raise an error if length is unspecified" do
      assert_raise(Scaffolder::Errors::CoordinateError) do 
        Scaffolder::Region::Unresolved.new.sequence
      end
    end

  end
end
