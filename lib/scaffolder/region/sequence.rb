# Class for inserting fasta sequence into the genome scaffold. The
# #raw_sequence method is also responsible for applying each of the sequence
# inserts to the original sequence. The following example specifies the
# insertion of a sequence identified by the fasta header 'sequence1'. The
# example also outlines and insert to be added to the sequence in the region
# between 3 and 10.
#
#  - sequence:
#      source: 'sequence1'
#      inserts:
#        -
#          source: 'insert1'
#          open: 3
#          close: 10
class Scaffolder::Region::Sequence < Scaffolder::Region

  # Fasta identifier for this sequence
  #
  # @param [String]
  # @return [String]
  attribute :source

  # Array of inserts to add to this sequence. Default is an empty array.
  #
  # @return [Array]
  # @param [Array]
  # @see Scaffolder::Region::Insert
  attribute :inserts, :default => Array.new

  # Adds each of the sequence inserts to the raw sequence. Updates the sequence
  # length each time an insert is added to reflect the change.
  #
  # @return [String] original sequence with inserts added.
  # @raise [CoordinateError] if any insert open position is greater than the
  #   length of the original sequence
  # @raise [CoordinateError] if any insert close position is less than one
  # @raise [CoordinateError] if any insert open position is greater than the
  #   close position
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
