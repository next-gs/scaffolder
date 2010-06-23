require 'yaml'
require 'bio'

class Scaffolder

  def self.read(scaffold_file,sequence_file)
    sequences = Hash[ *Bio::FlatFile::auto(sequence_file).collect { |s|
      [s.definition.split.first,s]
    }.flatten]

    YAML.load(File.open(scaffold_file).read).map do |r|
      type, data = r.keys.first, r.values.first

      case type
      when 'sequence' then
        seq = sequences[r['sequence']['source']]
        raise ArgumentError.new("Fasta sequence not found: #{r['sequence']['source']}") unless seq
        self.sequence(data,seq)
      when 'unresolved' then
        self.unresolved(data)
      else raise ArgumentError.new("Unknown sequence tag: #{type}")
      end
    end
  end

  attr_accessor :type, :start, :end, :name, :sequence

  def initialize(type)
    @type = type
  end

  def self.sequence(data,sequence)
    s          = Scaffolder.new('sequence')
    s.name     = data['source']
    s.sequence = sequence.seq

    s.start = data['start'] || 1
    raise ArgumentError.new("Sequence start less than 0") if s.start < 0

    s.end = data['end'] || sequence.length
    raise ArgumentError.new("Sequence end greater than length") if s.end > sequence.length

    s
  end

  def self.unresolved(data)
    s          = Scaffolder.new('unresolved')
    s.start    = 1
    s.end      = data['length']
    s.sequence = 'N' * data['length']
    s
  end

end
