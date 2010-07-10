module Scaffolder
  class Region

    attr_accessor :type, :start, :end, :name, :sequence, :length

    def initialize(type,sequence,options)
      @type     = type
      @name     = options[:name]
      @start    = options[:start] || 1
      @end      = options[:end]   || sequence.length
      @sequence = sequence[(@start-1)..(@end-1)]
      if options[:reverse]
        @sequence = Bio::Sequence::NA.new(@sequence).reverse.complement
        @sequence = @sequence.to_s.upcase
      end
      @length   = (@end - @start) + 1

      raise ArgumentError.new("Sequence end greater than length") if @end > sequence.length
      raise ArgumentError.new("Sequence start less than 0") if @start < 1
      raise ArgumentError.new("Sequence start greater than end") if @start > @end
    end

  end
end
