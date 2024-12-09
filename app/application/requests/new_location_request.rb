# frozen_string_literal: true

require 'dry/monads'

module Leaf
  module Request
    # Request validation for new location input
    class NewLocationRequest
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      def call
        parsed = validate_params(@params)
        Success(parsed.value!)
      rescue StandardError => error # rubocop:disable Naming/RescuedExceptionsVariableName
        Failure("Validation error: #{error.message}")
      end

      private

      def validate_params(params)
        validation_result = validation_schema.call(params)
        if validation_result.success?
          Success(validation_result.to_h)
        else
          Failure('Invalid location input')
        end
      end

      def validation_schema
        Dry::Schema.Params do
          required(:location_query).filled(:string)
        end
      end
    end
  end
end
