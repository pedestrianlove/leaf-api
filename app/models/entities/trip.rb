# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'location'

module LeafAPI
  module Entity
    # This is a class to represent the concept of trip on the map.
    # This may include strategies like 'driving', 'bicycling', 'school_bus', 'walking', 'trasit'...etc.
    class Trip < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional.default(nil)
      attribute :strategy, String.enum('driving', 'bicycling', 'school_bus', 'walking', 'transit')
      attribute :origin, Location
      attribute :destination, Location
      attribute :duration, Strict::Integer
      attribute :distance, Strict::Integer

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
