# frozen_string_literal: true

module LeafAPI
  module GoogleMaps
    # Class to map the data from google maps api to the Trip entity
    class TripMapper
      def initialize(gateway_class, token)
        @token = token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find(starting_point, destination, mode)
        data = @gateway.distance_matrix(starting_point, destination, mode)
        data['mode'] = mode
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @token, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class)
          @data = data
          @location_mapper = LocationMapper.new(
            gateway_class, token
          )
        end

        def build_entity
          LeafAPI::Entity::Trip.new(
            id: nil,
            strategy: strategy,
            origin: origin,
            destination: destination,
            duration: duration,
            distance: distance
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
          @data['rows'][0]['elements'][0]['duration']['value']
        end

        def distance
          @data['rows'][0]['elements'][0]['distance']['value']
        end
      end
    end
  end
end
