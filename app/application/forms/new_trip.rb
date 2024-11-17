# frozen_string_literal: true

require 'dry-validation'

module Leaf
  module Forms
    # Form validation for trip
    class NewTrip < Dry::Validation::Contract
      STRATEGY_ARRAY = %w[driving transit bicycling walking].freeze

      params do
        required(:origin).filled(:string)
        required(:destination).filled(:string)
        required(:strategy).filled(:string)
      end

      rule(:strategy) do
        key.failure('invalid strategy') unless STRATEGY_ARRAY.include?(value)
      end
    end
  end
end
