# frozen_string_literal: true

require 'dry-validation'

module Leaf
  module Forms
    # Form validation for Github project URL
    class NewQuery < Dry::Validation::Contract
      MSG_INVALID_STRATEGY = ' is an invalid strategy.'
      STRATEGY_ARRAY = %w[driving transit bicycling walking].freeze

      params do
        required(:origin).filled(:string)
        required(:destination).filled(:string)
        required(:strategy).filled(:string)
      end

      rule(:strategy) do
        key.failure(MSG_INVALID_STRATEGY) unless STRATEGY_ARRAY.include? value
      end
    end
  end
end
