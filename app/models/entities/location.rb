# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LeafAPI
  module Entity
    # This is a class to represent the concept of location on the map.
    # This may include user's location, bus stop's location, or destination's location.
    class Location < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional.default(nil)
      attribute :name, String.optional
      attribute :latitude, Strict::Float.optional
      attribute :longitude, Strict::Float.optional

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
