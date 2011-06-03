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

  # Array of inserts to add to this sequence. Each array entry may be either a
  # Scaffolder::Region:Inserts or a corresponding to the attributes of an
  # Insert. In the case of the latter each hash is used to generate a new
  # Scaffolder::Region::Insert instance.
  #
  # @return [Array] Array of Scaffolder::Region::Insert
  # @param [Array] inserts Accepts an array of either
  #   Scaffolder::Region::Insert or a hash of insert keyword data.
  def inserts(inserts=nil)
    if inserts.nil?
      @inserts || Array.new
    else
      @inserts = inserts.map do |insert|
        if insert.instance_of? Insert
          insert
        else
          Insert.generate(insert)
        end
      end
    end
  end

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
    @updated_sequence ||= update_sequence_with_inserts
  end

  private

  def update_sequence_with_inserts
    # Set the sequence stop positon if not defined as the stop
    # position is updated as each insert is added
    @stop ||= raw_sequence.length

    return inserts.sort.reverse.inject(raw_sequence) do |seq,insert|
      raise CoordinateError if insert.open  > raw_sequence.length
      raise CoordinateError if insert.close < 1
      raise CoordinateError if insert.open  > insert.close

      seq[insert.position] = insert.sequence
      @stop += insert.size_diff

      seq
    end
  end
end
