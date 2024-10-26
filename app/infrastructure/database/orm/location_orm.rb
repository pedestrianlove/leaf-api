# frozen_string_literal: true

require 'sequel'

module LeafAPI
  module Database
    # Object-Relational Mapper for Location
    class LocationOrm < Sequel::Model(:locations)
      one_to_many :trips,
                  class: :'LeafAPI::Database::TripOrm',
                  key: :location_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(location_info)
        first(name: location_info[:name]) || create(location_info)
      end

      def to_attr_hash
        {
          id: id,
          name: name,
          latitude: latitude,
          longtitude: longtitude
        }
      end
    end
  end
end
