# frozen_string_literal: true

require 'dry/transaction'

module Leaf
  module Service
    # Service to handle adding a new location
    class AddLocation
      include Dry::Transaction

      step :validate_input
      step :fetch_location

      private

      # Step 1: Validate input
      def validate_input(input)
        result = Leaf::Request::NewLocationRequest.new(input).call
        result.to_monad # 確保返回 Success 或 Failure
      end

      # Step 2: Fetch location from external service
      def fetch_location(input)
        location_query = CGI.unescape(input[:location_query])

        mapper = Leaf::GoogleMaps::LocationMapper.new(
          Leaf::GoogleMaps::API,
          Leaf::App.config.GOOGLE_TOKEN
        )

        location_entity = mapper.find(location_query)
        location_entity ? Success(location_entity) : Failure('Location not found')
      rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
        Failure("Error fetching location: #{error}")
      end
    end
  end
end
