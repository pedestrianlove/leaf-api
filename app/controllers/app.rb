# frozen_string_literal: true

require 'roda'
require 'slim'
require_relative 'routes/location_routes'
require_relative 'routes/trip_routes'
require_relative '../../config/environment'

module Leaf
  # This is the main application class that handles routing in Leaf
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      setup_routes(routing)
    end

    private

    def setup_routes(routing)
      setup_root(routing)
      Leaf::LocationRoutes.setup(routing)
      Leaf::TripRoutes.setup(routing)
    end

    def setup_root(routing)
      routing.root do
        view 'home'
      end
    end
  end
end
