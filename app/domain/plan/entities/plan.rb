# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'location'
require_relative 'trip'
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
      attribute :distance, Strict::Integer.optional.default(0)
      attribute :duration, Strict::Integer.optional.default(0)

      def to_attr_hash
        to_hash.except(:id, :trips)
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def compute
        trip_mapper = Leaf::GoogleMaps::TripMapper.new(GoogleMaps::API, Leaf::App.config.GOOGLE_TOKEN)
        # 未來會放真的公車站，然後中間的trip_mapper也會換掉，但現在就先拿馬偕, 光復當中間站
        trips.append(trip_mapper.find(
                       origin.plus_code,
                       'RX2R+27 光復里 Hsinchu City, East District',
                       strategy
                     ))
        trips.append(trip_mapper.find(
                       'RX2R+27 光復里 Hsinchu City, East District',
                       'QXXV+9J 光明里 Hsinchu City, East District',
                       'driving'
                     ))
        trips.append(trip_mapper.find(
                       'RX2R+27 光復里 Hsinchu City, East District',
                       destination.plus_code,
                       'walking'
                     ))

        new_distance = trips.map(&:distance).sum
        new_duration = trips.map(&:duration).sum

        new(
          id: id,
          origin: origin,
          destination: destination,
          strategy: strategy,
          trips: trips,
          distance: new_distance,
          duration: new_duration
        )
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
