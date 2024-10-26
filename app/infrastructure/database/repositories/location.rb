# frozen_string_literal: true

module LeafAPI
  module Repository
    # Repository for Location
    class Location
      def self.find_by_id(id)
        db_record = Database::LocationOrm.first(id: id)
        rebuild_entity(db_record) if db_record
      end

      def self.find_by_name(name)
        db_record = Database::LocationOrm.first(name: name)
        rebuild_entity(db_record) if db_record
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Location.new(
          id: db_record.id,
          name: db_record.name,
          latitude: db_record.latitude,
          longitude: db_record.longitude
        )
      end

      def self.rebuild_many(db_record)
        db_record.map { |db_location| rebuild_entity(db_location) }
      end

      def self.db_find_or_create(entity)
        Database::LocationOrm.find_or_create(entity.to_attr_hash)
      end

      def self.trips_as_origin(location_entity)
        return [] unless location_entity.id

        db_trips = Database::TripOrm.where(origin_id: location_entity.id).all
        db_trips.map { |db_trip| Trip.rebuild_entity(db_trip) }
      end

      def self.trips_as_destination(location_entity)
        return [] unless location_entity.id

        db_trips = Database::TripOrm.where(destination_id: location_entity.id).all
        db_trips.map { |db_trip| Trip.rebuild_entity(db_trip) }
      end
    end
  end
end
