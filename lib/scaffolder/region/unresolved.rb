class Scaffolder::Region::Unresolved < Scaffolder::Region
  attribute :length

  def sequence_hook
    'N' * length
  end

end
