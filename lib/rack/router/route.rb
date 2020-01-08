module Rack
  module Router
    # Route = Struct.new(:http_method, :path, :path_parts, :value, :constraint, :content_type) do
    #   def value_for(env)
    #     return value unless value.is_a?(Proc)
    #     value.call(env)
    #   end
    # end


    class Route
      attr_reader :http_method, :path, :path_parts, :value, :constraint, :content_type, :accept

      def initialize(http_method:, path:, value:, constraint: nil, content_type: nil, accept: nil)
        @http_method = http_method.to_s.upcase
        @path = path
        @value = value
        @constraint = constraint
        @content_type = content_type ? Array.wrap(content_type) : nil
        @accept = accept ? Array.wrap(accept) : nil
        @path_parts = calculate_path_parts
      end

      def path_hash(request_path)
        request_path = request_path.to_s.gsub(/\..*\z/, '')
        request_path_parts = request_path.split('/').reject(&:empty?)
        pairs = path.split('/').map.with_index do |part, idx|
          next if part[0] != ':'
          [part[1..-1].to_sym, request_path_parts[idx]]
        end
        pairs.reject(&:nil?).to_h
      end

      def print_route
        str = "\t#{http_method} \t#{path}"
        str += "\tcontent_type=[#{content_type.join(',')}]" unless content_type.nil?
        str += "\taccept=[#{content_type.join(',')}]" unless accept.nil?
        str
      end

      private

      def calculate_path_parts
        path.split('/').map do |part|
          next part if part[0] != ':'
          PathPart.new constraint&.fetch(part[1..-1].to_sym, nil)
        end
      end
    end
  end
end
