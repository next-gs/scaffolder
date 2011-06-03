# Inserts are used to additional usually smaller sequences to larger sequences.
# The attributes in the sequence class are used to specify where the host
# sequence is 'opened' and 'closed' to add the insert. Either one of these two
# attributes may be ommitted. Omitting the 'open' attribute will cause the
# insert open position to be calculated based on the close minus the sequence
# length. The reverse is true if the close position is ommittted.
#
# @see Scaffolder::Region::Sequence Scaffolder::Region::Sequence for an
#   example on adding inserts to a sequence.
class Scaffolder::Region::Insert < Scaffolder::Region

  # Fasta identifier for the insert sequence
  #
  # @param [String]
  # @return [String]
  attribute :source

  # Open position where insert is added. Default is close position minus the
  # sequence length.
  #
  # @param [Integer]
  # @return [Integer]
  attribute :open,
    :default => lambda{|s| s.close - s.sequence_hook.length - 1 }

  # End position where insert is added. Default is open position plus the
  # sequence length.
  #
  # @param [Integer]
  # @return [Integer]
  attribute :close,
    :default => lambda{|s| s.open  + s.sequence_hook.length - 1 }

  # Insertion position as a Range
  #
  # @return [Range]
  # @raise [CoordinateError] if both the open and close positions are nil.
  def position
    raise CoordinateError if @close.nil? && @open.nil?
    open-1..close-1
  end

  # Inserts are comparable by close position.
  #
  # @return [Integer]
  # @param [Scaffolder::Region::Insert]
  def <=>(other)
    self.close <=> other.close
  end

  # The difference in the insert sequence size and the insert location
  #
  # @return [Integer]
  def size_diff
    insert_size = (close - open) + 1
    sequence.length - insert_size
  end

end
