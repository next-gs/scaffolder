require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'redgreen'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'scaffolder'

class Test::Unit::TestCase
  require 'tempfile'

  def temporary_scaffold_file(hash)
    tmp = Tempfile.new(Time.now)
    File.open(tmp.path,'w+'){|f| f.write(YAML.dump(hash))}
    tmp.path
  end

end
