require 'delegate'
require 'bio'

class Scaffolder < DelegateClass(Array)
  require 'scaffolder/errors'
  require 'scaffolder/region'

  def initialize(assembly,sequence)
    sequences = Hash[ *Bio::FlatFile::auto(sequence).collect { |s|
      [s.definition.split.first,s.seq]
    }.flatten]

    super(assembly.map do |entry|
      type, data = entry.keys.first, entry.values.first
      Scaffolder::Region[type].generate(data)
    end)
  end

end
