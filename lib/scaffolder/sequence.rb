module Scaffolder
  class Sequence < Region

    def initialize(data,sequences)
      id       = data['source']
      sequence = sequences[id]
      raise ArgumentError.new("Fasta sequence not found: #{id}") unless sequence
      
      length = sequence.length

      if data['inserts']
        inserts = data['inserts'].map do |i|
          insert   = sequences[i['source']]
          raise ArgumentError.new("Sequence not found: #{id}") unless insert
          Insert.new(:start => i['start'], :stop => i['end'], :sequence => insert)
        end

        inserts.sort.reverse.each do |insert|

          if insert.start > sequence.length
            raise ArgumentError.new("Insert start #{insert.start} greater than length")
          end

          if insert.stop < 1
            raise ArgumentError.new("Insert end #{insert.stop} before sequence start")
          end

          sequence[insert.position] = insert.sequence
        end
      end

      super('sequence',sequence,{
        :name    => data['source'],
        :start   => data['start'],
        :end     => data['end'],
        :reverse => data['reverse']
      })
    end

  end
end
