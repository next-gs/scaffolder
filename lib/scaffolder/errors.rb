# Mixin module to define standard errors for scaffolder.
#
module Scaffolder::Errors
  exceptions = %w[ UnknownAttributeError CoordinateError ]
  exceptions.each { |e| const_set(e, Class.new(StandardError)) }
end
