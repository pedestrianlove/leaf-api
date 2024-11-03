# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'trip'
require_relative 'location'
require_relative '../utils'

module Leaf
  module Entity
    # for plan
    class Plan < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional.default(nil)
      attribute :origin, Location
      attribute :destination, Location
      attribute :strategy, String.enum('driving', 'bicycling', 'school_bus', 'walking', 'transit')
      attribute :trips, Strict::Array.of(Trip).optional
      attribute :distance_to, Strict::Integer.optional.default(0)
      attribute :query_id, String

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
