require 'delegate'
require 'bio'

module Scaffolder
  class Scaffold < DelegateClass(Array)

    def self.new(scaffold_file,sequence_file)
      sequences = Hash[ *Bio::FlatFile::auto(sequence_file).collect { |s|
        [s.definition.split.first,s]
      }.flatten]

      d = YAML.load(File.read(scaffold_file)).map do |r|
        type, data = r.keys.first, r.values.first

        case type
        when 'sequence' then
          seq = sequences[r['sequence']['source']]
          raise ArgumentError.new("Fasta sequence not found: #{r['sequence']['source']}") unless seq
          self.sequence(data,seq.seq)
        when 'unresolved' then
          self.unresolved(data)
        else raise ArgumentError.new("Unknown sequence tag: #{type}")
        end
      end
      super(d)
    end

    def self.sequence(data,sequence)
      Scaffolder::Region.new('sequence',sequence,{
        :name    => data['source'],
        :start   => data['start'],
        :end     => data['end'],
        :reverse => data['reverse']
      })
    end

    def self.unresolved(data)
      Scaffolder::Region.new('unresolved', 'N'*data['length'],
        :name =>'unresolved'
      )
    end

  end
end
