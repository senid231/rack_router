module Rack
  module Router
    class RouteBuilder
      def initialize
        @routes = []
      end

      # @param http_method [Symbol,String]
      # @param path [String]
      # @param value [String, Proc<Hash>]
      # @param options [Hash]
      #   :constraint [Hash<Symbol,Proc<String>>]
      #   :content_type [Array<String>,String]
      def add(http_method, path, value, options = {})
        path = path.split('/').reject(&:empty?).join('/')
        route = Route.new(
            http_method: http_method.to_s.upcase,
            path: path,
            value: value,
            **options
        )
        @routes.push(route)
        route
      end

      def match(env)
        http_method = env[Rack::REQUEST_METHOD]
        path = env[Rack::PATH_INFO].to_s.gsub(/\..*\z/, '')
        content_type, *_ = env['CONTENT_TYPE'].to_s.split(';')
        content_type = nil if !content_type.nil? && content_type.empty?
        accept, *_ = env['HTTP_ACCEPT'].to_s.split(';')
        accept = accept.to_s.split(',')

        match_request(http_method, path, content_type: content_type, accept: accept)
      end

      # @param http_method [String] upcase GET POST PUT PATCH DELETE HEAD
      # @param path [String]
      # @param content_type [String, NilClass]
      # @param accept [Array]
      def match_request(http_method, path, content_type: nil, accept: [])
        path_parts = path.split('/').reject(&:empty?)
        @routes.detect do |route|
          next false if route.http_method && route.http_method != http_method
          next false if route.content_type && route.content_type.include?(content_type)
          next false if route.accept && (route.accept & accept).empty? && !accept.include?('*/*')
          next false if route.path_parts.size != path_parts.size
          next false if route.path_parts.map.with_index { |part, idx| part != path_parts[idx] }.any?
          true
        end
      end

      def print_routes
        "Routes (#{@routes.size}):\n" + @routes.map(&:print_route).join("\n") + "\n"
      end
    end
  end
end
