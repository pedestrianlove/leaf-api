# frozen_string_literal: true

require 'roda'
require 'slim'
require 'rack'
require_relative 'routes/location_routes'
require_relative 'routes/trip_routes'
require_relative 'routes/query_routes'
require_relative '../../config/environment'

module Leaf
  # This is the main application class that handles routing in Leaf
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt
    plugin :flash
    plugin :all_verbs
    use Rack::MethodOverride

    # Configure Rack::Session for cookie-based session management
    use Rack::Session::Cookie, secret: App.config.SESSION_SECRET

    # 之後你們看還有哪些message要加的，我先試用這些而已
    MESSAGES = {
      no_info: 'No info input',
      db_error: 'Database access error',
      info_not_found: 'Info not found'
    }.freeze

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
      Leaf::QueryRoutes.setup(routing)
    end

    def setup_root(routing)
      routing.root do
        session[:query_id_visited] ||= []

        # Display a flash message if no locations have been viewed
        flash.now[:notice] = MESSAGES[:no_info] if session[:query_id_visited].empty?

        view 'home', locals: { query_id: session[:query_id_visited] }
      end
    end
  end
end
