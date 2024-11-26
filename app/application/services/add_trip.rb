# frozen_string_literal: true

require 'securerandom'
require 'dry/transaction'

module Leaf
  module Service
    # Service to handle trip creation and computation
    class AddTrip
      include Dry::Transaction

      step :validate_input
      step :map_trip
      step :create_trip
      step :save_trip

      private

      def validate_input(input)
        result = Leaf::Requests::NewTripRequest.new(input).call
        result.to_monad # Ensure result is already a Dry::Monads object (Success/Failure)
      end

      def map_trip(input)
        origin, destination, strategy = TripMapping.prepare_trip_params(input)
        mapper = Leaf::GoogleMaps::TripMapper.new(
          Leaf::GoogleMaps::API,
          Leaf::App.config.GOOGLE_TOKEN
        )
        mapped_trip = mapper.find(origin, destination, strategy)
        Success(mapped_trip.to_h)
      rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
        Failure("Mapping trip failed: #{error.message}")
      end

      def create_trip(input)
        trip = TripFactory.build(input)
        Success(trip: trip)
      rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
        Failure("Trip creation failed: #{error.message}")
      end

      def save_trip(input)
        trip = input[:trip]
        trip = Leaf::Repository::Trip.save(trip)
        Success(trip.id)
      rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
        Failure("Trip saving failed: #{error.message}")
      end
    end

    # Factory to build a trip entity
    class TripFactory
      def self.build(input)
        Entity::Trip.new(
          origin: input[:origin],
          destination: input[:destination],
          strategy: input[:strategy],
          distance: input[:distance],
          duration: input[:duration]
        )
      end
    end

    # Mapping class to prepare trip parameters
    class TripMapping
      def self.prepare_trip_params(input)
        origin = CGI.unescape(input[:origin])
        destination = CGI.unescape(input[:destination])
        strategy = CGI.unescape(input[:strategy])
        [origin, destination, strategy]
      end
    end
  end
end
