# frozen_string_literal: true

require 'sequel'

module LeafAPI
  module Database
    # Object-Relational Mapper for Trip
    class TripOrm < Sequel::Model(:trips)
      many_to_one :origin,
                  class: :'LeafAPI::Database::LocationOrm',
                  key: :origin_id

      many_to_one :destination,
                  class: :'LeafAPI::Database::LocationOrm',
                  key: :destination_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(trip_info)
        first(
          origin_id: trip_info[:origin_id],
          destination_id: trip_info[:destination_id],
          strategy: trip_info[:strategy],
          duration: trip_info[:duration],
          distance: trip_info[:distance]
        ) || create(trip_info)
      end
    end
  end
end
