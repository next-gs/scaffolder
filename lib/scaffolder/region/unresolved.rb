class Scaffolder::Region::Unresolved < Scaffolder::Region
  attribute :length

  def sequence_hook
    raise CoordinateError if length.nil?
    'N' * length
  end

end
