require 'scaffolder'

class Scaffolder::Region
  include Scaffolder::Errors

  class << self
    include Scaffolder::Errors

    def [](type)
      self.const_get(type.capitalize)
    end

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

  attribute :raw_sequence
  attribute :start,       :default => 1
  attribute :stop,        :default => lambda{|s| s.sequence_hook.length}
  attribute :reverse

  def sequence_hook
    raw_sequence
  end

  def entry_type
    self.class.name.split('::').last.downcase.to_sym
  end

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
