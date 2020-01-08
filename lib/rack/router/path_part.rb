module Rack
  module Router
    class PathPart
      attr_reader :constraint

      def initialize(constraint)
        @constraint = constraint
      end

      def ==(str)
        return true if constraint.nil?
        !!constraint.call(str)
      rescue TypeError, ArgumentError
        false
      end
    end
  end
end
