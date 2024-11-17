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
        form = Leaf::Forms::NewTrip.new.call(input)
        form.success? ? Success(form.to_h) : Failure("Validation failed: #{form.errors.to_h.values.join(', ')}")
      end

      def map_trip(input)
        origin, destination, strategy = prepare_trip_params(input)
        mapper = initialize_trip_mapper
        mapped_trip = mapper.find(origin, destination, strategy)
        Success(mapped_trip.to_h)
      rescue StandardError => e
        Failure("Mapping trip failed: #{e.message}")
      end

      def create_trip(input)
        trip = Entity::Trip.new(
          origin: input[:origin],
          destination: input[:destination],
          strategy: input[:strategy],
          distance: input[:distance],
          duration: input[:duration]
        )
        Success(trip: trip)
      rescue StandardError => e
        Failure("Trip creation failed: #{e.message}")
      end

      def save_trip(input)
        trip = input[:trip]
        trip = Leaf::Repository::Trip.save(trip)
        Success(trip.id)
      rescue StandardError => e
        Failure("Trip saving failed: #{e.message}")
      end

      def prepare_trip_params(input)
        origin = CGI.unescape(input[:origin])
        destination = CGI.unescape(input[:destination])
        strategy = CGI.unescape(input[:strategy])
        [origin, destination, strategy]
      end

      def initialize_trip_mapper
        Leaf::GoogleMaps::TripMapper.new(
          Leaf::GoogleMaps::API,
          Leaf::App.config.GOOGLE_TOKEN
        )
      end
    end
  end
end
