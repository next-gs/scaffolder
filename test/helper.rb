require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'redgreen'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'scaffolder'
require 'scaffolder/scaffold'
require 'scaffolder/region'

class Test::Unit::TestCase
  require 'tempfile'

  def temporary_scaffold_file(hash)
    tmp = Tempfile.new(Time.now)
    File.open(tmp.path,'w+'){|f| f.write(YAML.dump(hash))}
    tmp.path
  end

  def self.should_throw_argument_error &block
    should "throw an argument error" do
      scaffold_map, sequence_file = instance_eval(&block)
      tmp_map_file = temporary_scaffold_file(scaffold_map)
      begin
        Scaffolder::Scaffold.new(tmp_map_file,@sequence)
        flunk "Should throw an error"
      rescue ArgumentError
      end
    end
  end

end
