# frozen_string_literal: true

require_relative '../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../config/environment'

module LeafAPI
  # Module handling trip-related routes
  module TripRoutes
    def self.setup(routing, config)
      routing.on 'trips' do
        setup_trip_submit(routing)
        setup_trip_form(routing)
        setup_trip_result(routing, config)
      end
    end

    def self.setup_trip_submit(routing)
      routing.post 'submit' do
        params = routing.params
        routing.redirect "#{params['origin']}/#{params['destination']}/#{params['strategy']}"
      end
    end

    def self.setup_trip_form(routing)
      routing.is do
        routing.get do
          routing.scope.view 'trip_form'
        end
      end
    end

    def self.setup_trip_result(routing, config)
      routing.on String, String, String do |origin, destination, strategy|
        routing.get do
          trip_params = { origin: origin, destination: destination, strategy: strategy }
          trip = find_trip(trip_params, config)
          routing.scope.view('trip_result', locals: { trip: trip })
        end
      end
    end

    def self.find_trip(trip_params, config)
      trip_params[:origin] ||= '24.795707, 120.996393'
      trip_params[:destination] ||= '24.786930, 120.988428'
      trip_params[:strategy] ||= 'walking'

      trip_entities(trip_params, config)
    end

    def self.trip_entities(trip_params, config)
      mapper = LeafAPI::GoogleMaps::TripMapper.new(
        LeafAPI::GoogleMaps::API,
        config['GOOGLE_TOKEN']
      )

      mapper.find(
        CGI.unescape(trip_params[:origin]),
        CGI.unescape(trip_params[:destination]),
        CGI.unescape(trip_params[:strategy])
      )
    end
  end
end
