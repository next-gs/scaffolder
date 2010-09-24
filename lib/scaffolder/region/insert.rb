class Scaffolder::Region::Insert < Scaffolder::Region

  attribute :source
  attribute :open,  :default => lambda{|s| s.close - s.sequence_hook.length - 1 }
  attribute :close, :default => lambda{|s| s.open  + s.sequence_hook.length - 1 }

  def position
    raise CoordinateError if @close.nil? && @open.nil?
    open-1..close-1
  end

  def <=>(other)
    self.close <=> other.close
  end

end
