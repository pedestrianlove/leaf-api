# frozen_string_literal: true

require 'securerandom'
require 'dry/transaction'

module Leaf
  module Service
    # Transaction to store project from Github API to database
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    class AddQuery
      include Dry::Transaction

      step :parse_locations
      step :create_query
      step :compute_query
      step :save_query

      private

      def parse_locations(input)
        if input.success?
          location_mapper = GoogleMaps::LocationMapper.new(GoogleMaps::API, App.config.GOOGLE_TOKEN)

          origin = location_mapper.find(input[:origin])
          destination = location_mapper.find(input[:destination])
          strategy = input[:strategy]

          Success(origin: origin, destination: destination, strategy: strategy)
        else
          Failure("Parse query location: #{input.errors.messages.first}")
        end
      end

      def create_query(input)
        query = Entity::Query.new({ id: SecureRandom.uuid,
                                    origin: input[:origin],
                                    destination: input[:destination],
                                    strategy: input[:strategy],
                                    plans: [], distance: 0, duration: 0 })
        Success(query: query)
      rescue StandardError => e
        Failure("Create query: #{e}")
      end

      def compute_query(input)
        query = input[:query]
        query.compute
        Success(query: query)
      rescue StandardError => e
        Failure("Compute query: #{e}")
      end

      def save_query(input)
        query = input[:query]
        Leaf::Repository::Query.save(query)
        Success(query.id)
      rescue StandardError => e
        Failure("Save query: #{e}")
      end
    end
  end
end
