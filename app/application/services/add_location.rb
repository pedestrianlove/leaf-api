# frozen_string_literal: true

require 'dry/transaction'

module Leaf
  module Service
    # Service to handle adding a new location
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    class AddLocation
      include Dry::Transaction

      step :validate_input
      step :fetch_location

      private

      # Step 1: Validate input
      def validate_input(input)
        if input[:location_query].to_s.strip.empty?
          Failure('Validation failed: location_query cannot be empty')
        else
          Success(input)
        end
      rescue StandardError => e
        Failure("Validation error: #{e.message}")
      end

      def fetch_location(input)
        location_query = CGI.unescape(input[:location_query])
        # puts("Decoded Location Query: #{location_query}")

        mapper = Leaf::GoogleMaps::LocationMapper.new(
          Leaf::GoogleMaps::API,
          Leaf::App.config.GOOGLE_TOKEN
        )

        location_entity = mapper.find(location_query)
        location_entity ? Success(location_entity) : Failure('Location not found')
      rescue StandardError => e
        Failure("Error fetching location: #{e}")
      end
    end
  end
end
