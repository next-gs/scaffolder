require 'delegate'
require 'bio'

module Scaffolder
  class Scaffold < DelegateClass(Array)

    def self.new(scaffold_file,sequence_file)
      sequences = Hash[ *Bio::FlatFile::auto(sequence_file).collect { |s|
        [s.definition.split.first,s.seq]
      }.flatten]

      d = YAML.load(File.read(scaffold_file)).map do |r|
        type, data = r.keys.first, r.values.first

        case type
        when 'sequence' then
          Scaffolder::Sequence.new(data,sequences)
        when 'unresolved' then
          Scaffolder::Region.new('unresolved', 'N'*data['length'],
            :name =>'unresolved'
          )
        else raise ArgumentError.new("Unknown sequence tag: #{type}")
        end
      end
      super(d)
    end


  end
end
