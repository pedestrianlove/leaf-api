# frozen_string_literal: true

require 'ostruct'
require 'roar/decorator'
require 'roar/json'

require_relative 'plan'

module Leaf
  module Representer
    # Represents a CreditShare value
    class Query < Roar::Decorator
      include Roar::JSON

      property :id
      property :origin, extend: Representer::Location, class: OpenStruct
      property :destination, extend: Representer::Location, class: OpenStruct
      property :strategy
      collection :plans, extend: Representer::Plan, class: OpenStruct
    end
  end
end
