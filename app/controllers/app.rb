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

    MESSAGES = {
      no_info: 'No info input',
      db_error: 'Database access error',
      info_not_found: 'Info not found',
      api_error: 'Failed to retrieve data from external API',
      invalid_data: 'Invalid data received',
      save_error: 'Error saving data to database'
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
        initialize_session
        set_flash_message_for_empty_session

        render_home_view
      rescue StandardError => standard_error # rubocop:disable Naming/RescuedExceptionsVariableName
        handle_standard_error(standard_error)
      end
    end

    def initialize_session
      session[:query_id_visited] ||= []
    rescue StandardError => session_error # rubocop:disable Naming/RescuedExceptionsVariableName
      handle_session_error(session_error)
    end

    def handle_session_error(error)
      flash.now[:error] = "#{MESSAGES[:db_error]}: Failed to initialize session - #{error.message}"
    end

    def set_flash_message_for_empty_session
      set_no_info_message if session[:query_id_visited].empty?
    rescue StandardError => flash_error # rubocop:disable Naming/RescuedExceptionsVariableName
      handle_flash_error(flash_error)
    end

    def set_session_error_message
      flash.now[:error] = "#{MESSAGES[:db_error]}: Session data is missing"
    end

    def set_no_info_message
      flash.now[:notice] = MESSAGES[:no_info]
    end

    def handle_flash_error(error)
      flash.now[:error] = "#{MESSAGES[:db_error]}: Failed to set flash message - #{error.message}"
    end

    def render_home_view
      if session[:query_id_visited]
        view 'home', locals: { query_id: session[:query_id_visited] }
      else
        flash.now[:error] = "#{MESSAGES[:info_not_found]}: Unable to retrieve query data"
        view 'error'
      end
    rescue StandardError => render_error # rubocop:disable Naming/RescuedExceptionsVariableName
      handle_render_error(render_error)
      view 'error'
    end

    def handle_render_error(error)
      flash.now[:error] = "#{MESSAGES[:db_error]}: Failed to render home view - #{error.message}"
    end

    def handle_standard_error(error)
      flash.now[:error] = "#{MESSAGES[:db_error]}: #{error.message}"
      view 'home'
    end
  end
end
