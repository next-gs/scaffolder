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

      # Source is the only keyword. Used to fetch sequence from fasta file.
      data['raw_sequence'] = sequences[data['source']] if data['source']

      Scaffolder::Region[type].generate(data)
    end)
  end

end
