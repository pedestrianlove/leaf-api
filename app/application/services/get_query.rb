# frozen_string_literal: true

require 'dry/transaction'
require_relative '../../presentation/responses/api_result'

module Leaf
  module Service
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    class GetQuery
      include Dry::Monads::Result::Mixin

      def call(input)
        query = Leaf::Repository::Query.find_by_id(input)

        Success(APIResponse::ApiResult.new(status: :ok, message: query))
      rescue StandardError => e
        Failure(APIResponse::ApiResult.new(status: :not_found, message: "Fetching query: #{e}"))
      end
    end
  end
end
