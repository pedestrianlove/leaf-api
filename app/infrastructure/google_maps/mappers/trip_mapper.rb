# frozen_string_literal: true

module Leaf
  module GoogleMaps
    # Class to map the data from Google Maps API to the Trip entity
    class TripMapper
      def initialize(gateway_class, token)
        @token = token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find(starting_point, destination, mode, query_id)
        data = @gateway.distance_matrix(starting_point, destination, mode)
        data['mode'] = mode
        build_entity(data, query_id)
      end

      def build_entity(data, query_id)
        DataMapper.new(data, @token, @gateway_class, query_id).build_entity
      end

      # DataMapper class extracts entity-specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class, query_id)
          @data = data
          @query_id = query_id
          @location_mapper = LocationMapper.new(gateway_class, token)
        end

        def build_entity
          Leaf::Entity::Trip.new(
            id: nil,
            strategy: strategy,
            origin: origin,
            destination: destination,
            duration: duration,
            distance: distance,
            query_id: @query_id
          )
        end

        def strategy
          @data['mode']
        end

        def origin
          @location_mapper.find(@data['origin_addresses'][0])
        end

        def destination
          @location_mapper.find(@data['destination_addresses'][0])
        end

        def duration
          @data.dig('rows', 0, 'elements', 0, 'duration', 'value') || 0
        end

        def distance
          @data.dig('rows', 0, 'elements', 0, 'distance', 'value') || 0
        end
      end
    end
  end
end
