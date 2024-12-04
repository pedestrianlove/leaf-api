# frozen_string_literal: true

require 'ostruct'
require 'roar/decorator'
require 'roar/json'
require_relative 'location_formal'

module Leaf
  module Representer
    # Represents a CreditShare value
    class Trip < Roar::Decorator
      include Roar::JSON

      property :id
      property :strategy
      property :origin, extend: Representer::Location, class: OpenStruct
      property :destination, extend: Representer::Location, class: OpenStruct
      property :duration
      property :distance
    end
  end
end
