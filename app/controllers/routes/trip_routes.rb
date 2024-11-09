# frozen_string_literal: true

require 'securerandom'
require_relative '../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../config/environment'

module Leaf
  # Module handling trip-related routes
  module TripRoutes
    def self.setup(routing)
      routing.on 'trips' do
        setup_trip_submit(routing)
        setup_trip_form(routing)
        setup_trip_result(routing)
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
          routing.scope.view 'trip/trip_form'
        end
      end
    end

    def self.setup_trip_result(routing)
      routing.on String, String, String do |origin, destination, strategy|
        routing.get do
          trip_params = { origin: origin, destination: destination, strategy: strategy }
          trip = find_trip(trip_params)
          routing.scope.view('trip/trip_result', locals: { trip: trip })
        end
      end
    end

    def self.find_trip(trip_params)
      trip_params[:origin] ||= '24.795707, 120.996393'
      trip_params[:destination] ||= '24.786930, 120.988428'
      trip_params[:strategy] ||= 'walking'

      trip_entities(trip_params)
    end

    def self.trip_entities(trip_params)
      mapper = initialize_trip_mapper
      origin, destination, strategy = prepare_params(trip_params)

      mapper.find(origin, destination, strategy)
    end

    # Helper methods to make `trip_entities` more concise
    def self.initialize_trip_mapper
      Leaf::GoogleMaps::TripMapper.new(
        Leaf::GoogleMaps::API,
        Leaf::App.config.GOOGLE_TOKEN
      )
    end

    def self.prepare_params(trip_params)
      [
        CGI.unescape(trip_params[:origin]),
        CGI.unescape(trip_params[:destination]),
        CGI.unescape(trip_params[:strategy])
      ]
    end
  end
end
