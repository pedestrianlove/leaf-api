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
        schedule_mapper = Leaf::NTHUSA::ScheduleMapper.new(Leaf::NTHUSA::API)

        # 從起點到車站
        initial_trip = trip_mapper.find(
          origin.plus_code,
          initial_bus_stop.plus_code,
          strategy
        )
        initial_trip = Trip.new(
          origin: initial_trip.origin,
          destination: initial_bus_stop,
          strategy: initial_trip.strategy,
          distance: initial_trip.distance,
          duration: initial_trip.duration
        )

        # Compute the bus schedule
        schedules = schedule_mapper.find(initial_bus_stop.name, final_bus_stop.name)

        # Construct bus_trip entity
        tmp_bus_trip = trip_mapper.find(initial_bus_stop.plus_code, final_bus_stop.plus_code, 'driving')
        bus_trip = Trip.new(
          origin: initial_bus_stop,
          destination: final_bus_stop,
          strategy: 'driving',
          distance: tmp_bus_trip.distance,
          duration: (schedules.first.arrive_at - schedules.first.leave_at).round
        )

        # 從終點站到目的地
        final_trip = trip_mapper.find(
          final_bus_stop.plus_code,
          destination.plus_code,
          'walking'
        )
        final_trip = Trip.new(
          origin: final_bus_stop,
          destination: destination,
          strategy: 'walking',
          distance: final_trip.distance,
          duration: final_trip.duration
        )

        trip_list = [initial_trip, bus_trip, final_trip]
        new_distance = trip_list.map(&:distance).sum
        new_duration = trip_list.map(&:duration).sum
        leave_at = schedules.first.leave_at - initial_trip.duration
        arrive_at = schedules.first.arrive_at + final_trip.duration

        new(
          id: id,
          origin: origin,
          destination: destination,
          strategy: strategy,
          trips: trip_list,
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
