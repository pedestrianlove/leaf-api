# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Leaf
  module Representer
    # JSON Representer for Location entity
    class Location < Roar::Decorator
      include Roar::JSON

      property :name
      property :latitude
      property :longitude
      property :plus_code
    end
  end
end
