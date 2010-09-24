require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'redgreen'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'scaffolder'

class Test::Unit::TestCase
  class << self

    def should_have_method_attribute(klass)
      should "have method #attribute" do
        assert_respond_to( klass, :attribute )
      end
    end

    def should_have_attribute(klass, *attributes)
      attributes.each do |attribute|
        should "have instance attribute #{attribute}" do
          assert_respond_to( klass.new, attribute )
        end
      end
    end

  end
end
