# frozen_string_literal: true

require 'sequel'

module LeafAPI
  module Database
    # Object-Relational Mapper for Location
    class LocationOrm < Sequel::Model(:locations)
      plugin :timestamps, update_on_create: true

      one_to_many :trips_as_origin,
                  class: :'LeafAPI::Database::TripOrm',
                  key: :origin_id

      one_to_many :trips_as_destination,
                  class: :'LeafAPI::Database::TripOrm',
                  key: :destination_id

      def self.find_or_create(location_info)
        first(
          name: location_info[:name],
          latitude: location_info[:latitude],
          longitude: location_info[:longitude]
        ) || create(location_info)
      end
    end
  end
end
