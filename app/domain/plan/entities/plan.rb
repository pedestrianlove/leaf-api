# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require 'time'

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
      attribute :leave_at, Time.optional.default(nil)
      attribute :arrive_at, Time.optional.default(nil)

      def to_attr_hash
        to_hash.except(:id, :trips)
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def compute(initial_bus_stop, final_bus_stop)
        trip_mapper = Leaf::GoogleMaps::TripMapper.new(GoogleMaps::API, Leaf::App.config.GOOGLE_TOKEN)

        trip_array = []

        # 從起點到車站
        trip_array.append(trip_mapper.find(
                            origin.plus_code,
                            initial_bus_stop.plus_code,
                            strategy
                          ))

        # FIXME: 從車站到終點站
        trip_array.append(trip_mapper.find(
                            initial_bus_stop.plus_code,
                            final_bus_stop.plus_code,
                            'driving'
                          ))
        # FIXME: 從車站到終點站

        # 從終點站到目的地
        trip_array.append(trip_mapper.find(
                            final_bus_stop.plus_code,
                            destination.plus_code,
                            'walking'
                          ))

        new_distance = trips.map(&:distance).sum
        new_duration = trips.map(&:duration).sum
        leave_at = ::Time.now
        arrive_at = leave_at + new_duration

        new(
          id: id,
          origin: origin,
          destination: destination,
          strategy: strategy,
          trips: trip_array,
          distance: new_distance,
          duration: new_duration,
          leave_at: leave_at,
          arrive_at: arrive_at
        )
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
