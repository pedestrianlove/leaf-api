# frozen_string_literal: true

require_relative 'location'

module Leaf
  module Repository
    # Repository for Trip
    class Trip
      def self.all
        Database::TripOrm.all.map { |db_trip| rebuild_entity(db_trip) }
      end

      def self.find_by_id(id)
        db_record = Database::TripOrm.first(id: id)
        rebuild_entity(db_record) if db_record
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        origin_location = build_origin(db_record)
        destination_location = build_destination(db_record)

        build_trip_entity(db_record, origin_location, destination_location)
      end

      def self.build_origin(db_record)
        Location.find_by_id(db_record.origin_id)
      end

      def self.build_destination(db_record)
        Location.find_by_id(db_record.destination_id)
      end

      def self.build_trip_entity(db_record, origin_location, destination_location)
        Entity::Trip.new(
          id: db_record.id,
          strategy: db_record.strategy,
          origin: origin_location,
          destination: destination_location,
          duration: db_record.duration,
          distance: db_record.distance
        )
      end

      def self.rebuild_many(db_record)
        db_record.map { |db_trip| rebuild_entity(db_trip) }
      end

      def self.db_find_or_create(entity)
        origin = find_or_create_location(entity.origin)
        destination = find_or_create_location(entity.destination)

        db_record = find_or_create_trip(entity, origin, destination)

        rebuild_entity(db_record)
      end

      def self.find_or_create_location(location_entity)
        Location.db_find_or_create(location_entity)
      end

      def self.find_or_create_trip(entity, origin, destination)
        Database::TripOrm.find_or_create(
          origin_id: origin.id,
          destination_id: destination.id,
          strategy: entity.strategy,
          duration: entity.duration,
          distance: entity.distance
        )
      end

      def self.save(entity) # rubocop:disable Metrics/MethodLength
        origin = find_or_create_location(entity.origin)
        destination = find_or_create_location(entity.destination)

        db_trip = Database::TripOrm.find_or_create(
          origin_id: origin.id,
          destination_id: destination.id,
          strategy: entity.strategy,
          duration: entity.duration,
          distance: entity.distance
        )

        rebuild_entity(db_trip)
      rescue StandardError => e
        raise "Failed to save trip: #{e.message}"
      end
    end
  end
end
