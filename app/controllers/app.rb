# frozen_string_literal: true

require 'roda'
require 'slim'
require 'yaml'
require_relative '../models/entities/trip'
require_relative '../models/mappers/trip_mapper'
require_relative '../models/gateways/google_maps_api'
require_relative '../../config/environment'

CORRECT_SECRETS = YAML.safe_load_file('config/secrets.yaml')

module LeafAPI
  # This is the main application class that handles routing in LeafAPI
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
      setup_location_routes(routing)
      setup_trip_routes(routing)
    end

    def setup_root(routing)
      routing.root do
        view 'home'
      end
    end

    def setup_location_routes(routing)
      routing.on 'locations' do
        routing.get do
          view 'locations'
        end
      end
    end

    def setup_trip_routes(routing)
      routing.on 'trips' do
        setup_trip_submit(routing)

        setup_trip_form(routing)

        setup_trip_result(routing)
      end
    end

    def setup_trip_submit(routing)
      routing.post 'submit' do
        handle_submit(routing)
      end
    end

    def setup_trip_form(routing)
      routing.is do
        routing.get do
          view 'trip_form'
        end
      end
    end

    def setup_trip_result(routing)
      routing.on String, String do |origin, destination, strategy|
        routing.get do
          origin = routing.params['origin'] || '北校門口'
          destination = routing.params['destination'] || '台積館'
          strategy = routing.params['strategy'] || 'walking'
          trip = trip_entities(origin, destination, strategy)
          puts "Start: #{origin}, Destination: #{destination}, Strategy: #{strategy}"

          view 'trip_result', locals: { trip: trip }
        end
      end
    end

    def handle_submit(routing)
      trip_params = extract_trip_data(routing)
      puts "Received form data: #{routing.params.inspect}"
      routing.redirect "#{trip_params[:origin]}/#{trip_params[:destination]}/#{trip_params[:strategy]}"
    end

    def extract_trip_data(routing)
      {
        origin: routing.params['origin'],
        destination: routing.params['destination'],
        strategy: routing.params['strategy'] || 'walking'
      }
    end

    def trip_entities(origin, destination, strategy)
      mapper = LeafAPI::GoogleMaps::TripMapper.new(
        LeafAPI::GoogleMaps::API,
        CORRECT_SECRETS['GOOGLE_TOKEN']
      )
      mapper.find(origin, destination, strategy)
    end
  end
end
