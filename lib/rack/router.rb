require 'rack'
require 'rack/router/route'
require 'rack/router/route_builder'
require 'rack/router/path_part'
require 'rack/router/middleware'

module Rack
  module Router
    RACK_ROUTER_PATH = 'rack.router.path'.freeze
    RACK_ROUTER_PATH_HASH = 'rack.router.path_hash'.freeze
  end
end
