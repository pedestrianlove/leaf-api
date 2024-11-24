# frozen_string_literal: true

require 'dry-validation'

module Leaf
  module Request
    # Request validation for new location input
    class NewLocationRequest < Dry::Validation::Contract
      params do
        required(:location).filled(:string)
      end
    end
  end
end
