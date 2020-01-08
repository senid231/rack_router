require 'logger'

module Rack
  module Router
    class Middleware
      attr_reader :logger

      def initialize(app, logger: nil, &block)
        @app = app
        @routes = RouteBuilder.new
        @current_path = nil
        @current_options = {}
        @not_found = nil
        @logger = logger || Logger.new(STDOUT)
        @callbacks = []
        instance_exec(&block)
      end

      def call(env)
        route = @routes.match(env)
        env[RACK_ROUTER_PATH] = route&.value
        env[RACK_ROUTER_PATH_HASH] = route&.path_hash env[Rack::PATH_INFO]
        run_after_route(env, route)

        if route.nil? && !@not_found.nil?
          logger.debug { "#{self.class}#call route was not found\n#{@routes.print_routes}" }
          return render_not_found(env)
        end

        @app.call(env)
      end

      [:get, :post, :put, :patch, :delete, :option, :head].each do |http_method|
        # @param path [String]
        # @param value [String, Proc<Hash>]
        # @param options [Hash<Symbol>,Hash]
        #   :constraint [Hash<Symbol=>Proc<String>>]
        #   :content_type [Array<String>,String]
        define_method(http_method) do |path, value, options = {}|
          define_path(http_method, path, value, options)
        end
      end

      def match(path, value, options = {})
        define_path(nil, path, value, options)
      end

      # @param path [String]
      # @param options [Hash<Symbol>,Hash]
      #   :constraint [Hash<Symbol=>Proc<String>>]
      #   :content_type [String, Array<String>]
      def nested(path, options = {})
        old_current_path = @current_path
        old_current_options = @current_options
        @current_path = [@current_path, path].compact.join('/')
        @current_options = @current_options.dup.merge(options)
        yield
      ensure
        @current_path = old_current_path
        @current_options = old_current_options
      end

      # @param path [String]
      def namespace(path, &block)
        nested(path, {}, &block)
      end

      # @param constraint [Hash<Symbol,Proc<String>>]
      def with_constraint(constraint, &block)
        nested(nil, constraint: constraint, &block)
      end

      # @param content_type [String, Array<String>]
      def with_content_type(content_type, &block)
        nested(nil, content_type: content_type, &block)
      end

      # @param accept [String, Array<String>]
      def with_accept(accept, &block)
        nested(nil, accept: accept, &block)
      end

      # @param http_method [String,Symbol]
      # @param path [String]
      # @param value [String, Proc<Hash>]
      # @param options [Hash]
      #   :constraint [Hash<Symbol=>Proc<String>>]
      #   :content_type [Array<String>,String]
      def define_path(http_method, path, value, options = {})
        options = @current_options.dup.merge(options)
        path = [@current_path, path].reject(&:empty?).join('/')
        @routes.add(http_method, path, value, options)
      end

      def not_found(response)
        response = default_not_found if response == :default
        response = nil unless response
        @not_found = response
      end

      # @yield after route match executed
      # @yieldparam env [Hash]
      # @yieldparam route [Rack::Router::Route, NilClass]
      def after_route(&block)
        raise ArgumentError, 'block must be given' unless block_given?

        @callbacks.push(block)
      end

      private

      def run_after_route(env, route)
        @callbacks.each do |cb|
          instance_exec(env, route, &cb)
        end
      end

      def default_not_found
        [404, { Rack::CONTENT_TYPE => 'text/plain' }, ['Route not found']]
      end

      def render_not_found(env)
        return @not_found.call(env) if @not_found.is_a?(Proc)
        @not_found
      end
    end
  end
end
