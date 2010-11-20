# This class is used to insert unreolved sequence regions in to the genome
# build. The unresolved region is filled with N characters. The example below
# with insert the characters 'NNNNN' into the genome build.
#
#   - unresolved:
#       length: 5
# 
class Scaffolder::Region::Unresolved < Scaffolder::Region

  # The length of the unresolved region
  # @return [Integer]
  # @param [Integer]
  attribute :length

  # Calculate unresolved region sequence
  # @return [String] a string of Ns equal to length attribute
  # @raise [CoordinateError] if the length attribute is nil
  def sequence_hook
    raise CoordinateError if length.nil?
    'N' * length
  end

end
