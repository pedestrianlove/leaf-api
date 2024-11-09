# frozen_string_literal: true

module Leaf
  module Repository
    # Repository for Location
    class Location
      def self.find_by_id(id)
        db_record = Database::LocationOrm.first(id: id)
        rebuild_entity_if_present(db_record)
      end

      def self.find_by_name(name)
        db_record = Database::LocationOrm.first(name: name)
        rebuild_entity_if_present(db_record)
      end

      def self.rebuild_entity_if_present(db_record)
        db_record ? rebuild_entity(db_record) : nil
      end

      def self.rebuild_entity(db_record)
        Entity::Location.new(
          id: db_record.id,
          name: db_record.name,
          latitude: db_record.latitude,
          longitude: db_record.longitude,
          plus_code: db_record.plus_code
        )
      end

      def self.rebuild_many(db_records)
        db_records.map { |db_location| rebuild_entity(db_location) }
      end

      def self.db_find_or_create(entity)
        Database::LocationOrm.find_or_create(entity.to_attr_hash)
      end

      def self.trips_as_origin(location_entity)
        location_id = location_entity.id
        return [] unless location_id

        db_trips = Database::TripOrm.where(origin_id: location_id).all
        db_trips.map { |db_trip| Trip.rebuild_entity(db_trip) }
      end

      def self.trips_as_destination(location_entity)
        location_id = location_entity.id
        return [] unless location_id

        db_trips = Database::TripOrm.where(destination_id: location_id).all
        db_trips.map { |db_trip| Trip.rebuild_entity(db_trip) }
      end
    end
  end
end
