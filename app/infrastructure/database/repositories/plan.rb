# frozen_string_literal: true

require_relative 'location'

module Leaf
  module Repository
    # Repository for Trip
    class Plan
      # rubocop:disable Metrics:Methods
      def self.find_by_id(id)
        db_record = Database::PlanOrm.first(id: id)
        return nil unless db_record

        trip_record = Leaf::App.db.fetch('SELECT id FROM trips WHERE plan_id=?', db_record.id)
        return nil unless trip_record

        Entity::Plan.new({
                           id: db_record.id,
                           strategy: db_record.strategy,
                           origin: Location.find_by_id(db_record.origin_id),
                           destination: Location.find_by_id(db_record.destination_id),
                           duration: db_record.duration,
                           distance: db_record.distance,
                           trips: trip_record.map { |trip_rec| Trip.find_by_id(trip_rec[:id]) }
                         })
      end
      # rubocop:enable Metrics:Methods

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def self.save(plan, query_id = nil)
        origin = Database::LocationOrm.find_or_create(plan.origin.to_attr_hash)
        destination = Database::LocationOrm.find_or_create(plan.destination.to_attr_hash)
        db_plan = Database::PlanOrm.find_or_create(plan.to_attr_hash
          .except(:origin, :destination, :trips)
          .merge({
                   query_id: query_id,
                   origin_id: origin.id,
                   destination_id: destination.id
                 }))

        plan.trips.each do |trip|
          origin = Database::LocationOrm.find_or_create(plan.origin.to_attr_hash)
          destination = Database::LocationOrm.find_or_create(plan.destination.to_attr_hash)
          Database::TripOrm.find_or_create(trip.to_attr_hash
            .except(:origin, :destination)
            .merge({
                     plan_id: db_plan.id,
                     origin_id: origin.id,
                     destination_id: destination.id
                   }))
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
    end
  end
end
