class Scaffolder::Region::Sequence < Scaffolder::Region

  attribute :source
  attribute :inserts, :default => Array.new

  def sequence_hook
    # Set the sequence stop positon if not defined as the stop
    # position is updated as each insert is added
    @stop ||= raw_sequence.length

    return inserts.sort.reverse.inject(raw_sequence) do |seq,insert|
      raise CoordinateError if insert.open  > raw_sequence.length
      raise CoordinateError if insert.close < 1
      raise CoordinateError if insert.open  > insert.close

      before_size = seq.length
      seq[insert.position] = insert.sequence
      diff = seq.length - before_size
      stop(stop + diff)

      seq
    end
  end
end
