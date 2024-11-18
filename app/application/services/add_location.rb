# frozen_string_literal: true

require 'dry/transaction'

module Leaf
  module Service
    # Service to handle adding a new location
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    class AddLocation
      include Dry::Transaction

      step :fetch_location

      private

      def fetch_location(input)
        location_query = CGI.unescape(input[:location_query])
        puts("Decoded Location Query: #{location_query}")

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
