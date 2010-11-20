require 'scaffolder'

class Scaffolder::Region
  include Scaffolder::Errors

  class << self
    include Scaffolder::Errors

    # @return [Scaffolder::Region] Returns subclassed instances of
    #   Scaffolder::Region by name
    def [](type)
      self.const_get(type.capitalize)
    end

    # Links the specification of values in the scaffold file to the assignment
    # of instance variables.
    #
    # @param [Symbol] Define attributes for this type of scaffold
    #   region. Attributes are read from the scaffold file and stored as
    #   instance variables.
    # @param [Hash] options Attribute options.
    # @option options [Object,Proc] Default Specify a default value for this
    #   attribute if a value is not defined in the scaffold file.
    # @example Simple specification
    #   class MyRegion < Scaffolder::Region
    #     attribute :value # "value" usable as a keyword in the scaffold file
    #   end
    # @example Specification with a default value
    #   attribute :value, :default => 1
    # @example Specification with where proc is evaluated for the default
    #   attribute :value, :default => lamdba{ Time.now.to_s }
    # @example Specification with proc where the region instance is avaiable
    #   attribute :value, :default => lamdba{|s| s.other_variable + 1 }
    def attribute(name,options = {})
      define_method(name) do |*arg|
        var = "@#{name}"
        default = options[:default]
        unless arg.first # Is an argument is passed to the method?
          value = instance_variable_get(var)
          return value if value
          return default.respond_to?(:call) ? default.call(self) : default
        end
        instance_variable_set(var,arg.first)
      end
    end

    # Parse each key-value pair in the scaffold hash calling the corresponding
    # attribute method for the key and passing the value as an argument.
    #
    # @param [Hash] region_data Key-Value pairs of the data required to define
    #   this scaffolder region.
    # @return [Scaffolder::Region] Returns an region object where the
    #   instance variables have been assigned according to the region data
    #   hash.
    # @raise [UnknownAttributeError] If a keyword in the scaffold file does not
    #   have a corresponding attribute in the class.
    # @see Scaffolder::Region.attribute
    def generate(region_data)
      region = self.new
      region_data.each_pair do |attribute,value|
        begin
          region.send(attribute.to_sym,value)
        rescue NoMethodError => e
          raise UnknownAttributeError.new(e)
        end
      end
      region
    end

  end

  # The raw sequence for this region.
  #
  # @param [String]
  # @return [String]
  attribute :raw_sequence

  # Trim the start of sequence to this position. Default is 1.
  #
  # @param [Interger]
  # @return [Interger]
  attribute :start, :default => 1

  # Trim the end of sequence to this position. Default is the sequence length..
  #
  # @param [Interger]
  # @return [Interger]
  attribute :stop, :default => lambda{|s| s.sequence_hook.length}


  # Should the sequence be reverse complemented. Reverse complementation is
  # performed after the start and end of the sequence has been trimmed.
  #
  # @param [Boolean]
  # @return [Boolean]
  attribute :reverse

  # Override this to manipulate the sequence before it's subsequenced, reverse
  # complemented etc. by Scaffolder::Region#sequence.
  #
  # @return [String] The value of the raw_sequence attribute
  # @see Scaffolder::Region#sequence
  def sequence_hook
    raw_sequence
  end

  # The name of the class. Useful for selecting specific region types.
  #
  # @return [Symbol]
  def entry_type
    self.class.name.split('::').last.downcase.to_sym
  end

  # Returns the value of the Scaffolder::Region#raw_sequence after
  # subsequencing and reverse complementation (if specified in the
  # scaffold file).
  #
  # @return [String] Sequence after all modifications
  # @raise [CoordinateError] if the start position is less than 1.
  # @raise [CoordinateError] if the stop position is greater than the sequence
  #   length.
  # @raise [CoordinateError] if the start position is greater than the stop
  #   position.
  def sequence
    seq = sequence_hook

    raise CoordinateError.new if start < 1
    raise CoordinateError.new if stop  > seq.length
    raise CoordinateError.new if start > stop

    seq = seq[(start-1)..(stop-1)]
    seq = Bio::Sequence::NA.new(seq).reverse_complement if reverse
    seq.to_s.upcase
  end

  require 'scaffolder/region/unresolved'
  require 'scaffolder/region/insert'
  require 'scaffolder/region/sequence'
end
