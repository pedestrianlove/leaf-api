# frozen_string_literal: true

require 'securerandom'
require 'dry/transaction'
require_relative '../../presentation/responses/api_result'
require_relative '../../../workers/progress_reporter'

module Leaf
  module Service
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
        Leaf::ProgressReporter.report_progress(Leaf::App.config, input['id'], 20, 'Parsing location...')
        location_mapper = GoogleMaps::LocationMapper.new(GoogleMaps::API, App.config.GOOGLE_TOKEN)

        origin = location_mapper.find(input['origin'])
        destination = location_mapper.find(input['destination'])

        Success(id: input['id'], origin: origin, destination: destination, strategy: input['strategy'])
      rescue StandardError => e
        Failure(APIResponse::ApiResult.new(status: :internal_error,
                                           message: "Parse query location: #{e.message}"))
      end

      def create_query(input)
        Leaf::ProgressReporter.report_progress(Leaf::App.config, input[:id], 40, 'Creating entity...')
        query = Entity::Query.new({ id: input[:id],
                                    origin: input[:origin],
                                    destination: input[:destination],
                                    strategy: input[:strategy],
                                    plans: [], distance: 0, duration: 0 })
        Success(query: query)
      rescue StandardError => e
        Failure(APIResponse::ApiResult.new(status: :internal_error, message: "Create query: #{e}"))
      end

      def compute_query(input)
        query = input[:query]
        Leaf::ProgressReporter.report_progress(Leaf::App.config, query.id, 60, 'Computing query...')
        query.compute
        Success(query: query)
      rescue StandardError => e
        Failure("Compute query: #{e}")
      end

      def save_query(input)
        query = input[:query]
        Leaf::ProgressReporter.report_progress(Leaf::App.config, query.id, 80, 'Writing to database...')
        Leaf::Repository::Query.save(query)
        Success(APIResponse::ApiResult.new(status: :created, message: query))
      rescue StandardError => e
        Failure(APIResponse::ApiResult.new(status: :internal_error, message: "Save query: #{e}"))
      end
    end
  end
end
