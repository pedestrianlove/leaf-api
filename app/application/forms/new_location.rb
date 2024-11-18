# frozen_string_literal: true

require 'dry-validation'

module Leaf
  module Forms
    # Form validation for location input
    class NewLocation < Dry::Validation::Contract
      params do
        required(:location).filled(:string)
      end
    end
  end
end
