require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'redgreen'
require 'rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'scaffolder'

class Test::Unit::TestCase
  require 'tempfile'
  include RR::Adapters::TestUnit
end
