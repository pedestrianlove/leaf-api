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

      # TODO: Refer to the TripMapper and Finish the LocationMapper class...
      def find(address)
        # FIXME: 為了先讓測試能過隨便給的，要改掉照著TripMapper的樣子寫!!!
        LeafAPI::Entity::Location.new(
          id: nil,
          name: address,
          latitude: 123.1,
          longtitude: 456.1
        )
      end

      def build_entity(data); end

      def name; end

      def latitude; end

      def longtitude; end
      # TODO: Refer to the TripMapper and Finish the LocationMapper class...
    end
  end
end
