# frozen_string_literal: true

require 'roda'
require 'slim'
require 'rack'
require_relative 'routes/location_routes'
require_relative 'routes/trip_routes'
require_relative 'routes/query_routes'
require_relative '../../../config/environment'

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

    MESSAGES = {
      no_info: 'No info input',
      db_error: 'Database access error',
      info_not_found: 'Info not found',
      invalid_request: 'Invalid request parameters',
      missing_session: 'Session data is missing',
      route_error: 'Unexpected route error',
      unauthorized_access: 'Unauthorized access attempt'
    }.freeze

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      begin
        setup_routes(routing)
      rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
        App.logger.error error.backtrace.join("\n")
        flash[:error] = MESSAGES[:route_error]
        response.status = 500
        routing.redirect '/'
      end
    end

    private

    def setup_routes(routing)
      setup_root(routing)
      Leaf::LocationRoutes.setup(routing)
      Leaf::TripRoutes.setup(routing)
      Leaf::QueryRoutes.setup(routing)
    end

    def setup_root(routing) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      routing.root do
        session[:query_id_visited] ||= []

        flash.now[:notice] = MESSAGES[:no_info] if session[:query_id_visited].empty?

        begin
          view 'home', locals: { query_id: session[:query_id_visited] }
        rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
          App.logger.error error.backtrace.join("\n")
          flash[:error] = MESSAGES[:db_error]
          response.status = 500
        end
      end
    end
  end
end
