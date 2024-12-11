# frozen_string_literal: true

require 'dry/monads'
require 'json'

module Leaf
  module Requests
    # Handles input parsing and validation for new trip requests
    class NewTripRequest
      include Dry::Monads::Result::Mixin

      STRATEGY_ARRAY = %w[driving transit bicycling walking].freeze

      def initialize(params)
        @params = params
      end

      def call
        parsed = validate_params(@params)
        Success(parsed.value!)
      rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
        Failure("Parsing error: #{error.message}")
      end

      private

      def validate_params(params) # rubocop:disable Metrics/MethodLength
        validation_result = validation_schema.call(params)
        if validation_result.success?
          Success(validation_result.to_h)
        else
          Failure(
            Leaf::APIResponse::ApiResult.new(
              status: :bad_request,
              message: 'Invalidated trip input'
            )
          )
        end
      end

      def validation_schema
        Dry::Schema.Params do
          required(:origin).filled(:string)
          required(:destination).filled(:string)
          required(:strategy).filled(:string, included_in?: STRATEGY_ARRAY)
        end
      end
    end
  end
end
