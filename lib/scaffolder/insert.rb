class Scaffolder
  class Insert
    include Comparable

    attr_accessor :start, :stop, :sequence

    def initialize(options)
      @sequence = options[:sequence]
      @start    = options[:start]
      @stop     = options[:stop] || (@start + @sequence.length - 1)

      if options[:reverse]
        @sequence = Bio::Sequence::NA.new(@sequence).reverse_complement.seq.upcase
      end
    end

    def position
      @start-1..@stop-1
    end

    def <=>(other)
      self.stop <=> other.stop
    end

  end
end
