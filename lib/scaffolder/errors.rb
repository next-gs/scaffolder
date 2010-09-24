class Scaffolder
  module Errors
    exceptions = %w[ UnknownAttributeError CoordinateError ]
    exceptions.each { |e| const_set(e, Class.new(StandardError)) }
  end
end
