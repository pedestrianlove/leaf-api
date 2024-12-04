# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Leaf
  module Representer
    # Represents a CreditShare value
    class Location < Roar::Decorator
      include Roar::JSON

      property :id
      property :name
      property :longitude
      property :latitude
      property :plus_code
    end
  end
end
