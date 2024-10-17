# frozen_string_literal: true

module LeafAPI
  module GoogleMaps
    # Class to map the data from google maps api to the Trip entity
    class LocationMapper
      def initialize(gateway_class, token)
        @token = token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def find(address)
        data = @gateway.geocoding(address)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @token, @gateway_class).build_entity
      end

      # This class maps the response data from Google Maps API to a Location entity.
      # It extracts necessary information such as name, latitude, and longitude.
      class DataMapper
        def initialize(data, token, gateway_class)
          @data = data
          @location_mapper = LocationMapper.new(
            gateway_class, token
          )
        end

        def build_entity
          LeafAPI::Entity::Location.new(
            id: nil,
            name: name,
            latitude: latitude,
            longtitude: longtitude
          )
        end

        def name
          @data['results'][0]['formatted_address']
        end

        def latitude
          @data['results'][0]['geometry']['location']['lat']
        end

        def longtitude
          @data['results'][0]['geometry']['location']['lng']
        end
      end
    end
  end
end
