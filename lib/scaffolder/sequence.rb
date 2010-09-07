class Scaffolder
  class Sequence

    attr_accessor :entry_type, :start, :end, :name, :inserts, :raw_sequence

    def initialize(options)
      @entry_type   = :sequence
      @name         = options[:name]
      @start        = options[:start] || 1
      @end          = options[:end]   || options[:sequence].length
      @sequence     = options[:sequence]
      @raw_sequence = @sequence.clone
      @reverse      = options[:reverse]
      @inserts      = []

      raise ArgumentError.new("Sequence end greater than length") if @end > @raw_sequence.length
      raise ArgumentError.new("Sequence start less than 0") if @start < 1
      raise ArgumentError.new("Sequence start greater than end") if @start > @end

    end

    def add_inserts(inserts)
      @inserts = inserts.sort.reverse
      @inserts.each do |insert|
        if insert.start > @sequence.length
          raise ArgumentError.new("Insert start greater than length")
        end
        if insert.stop < 1
          raise ArgumentError.new("Insert end less than 1")
        end
        if insert.stop <= insert.start
          raise ArgumentError.new("Insert end less than start")
        end

        before_size = @sequence.length
        @sequence[insert.position] = insert.sequence

        # Update sequence end after adding inserts
        diff = @sequence.length - before_size
        @end += diff
      end
    end

    def sequence
      seq = @sequence[(@start-1)..(@end-1)]
      seq = Bio::Sequence::NA.new(seq).reverse_complement if @reverse
      seq.to_s.upcase
    end
  end
end
