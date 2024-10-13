# frozen_string_literal: true

require 'http'
require_relative 'api_errors'

module LeafAPI
  module Service
    # This is the service class to make API requests to Google Maps API:
    # https://api.nthusa.tw/docs
    class GoogleMapsAPI
      def initialize(secret = nil)
        @http = HTTP.accept(:json).follow.persistent('https://maps.googleapis.com')
        @secret = secret.nil? ? YAML.safe_load_file('config/secrets.yaml')['GOOGLE_TOKEN'] : secret
      end

      # Given 2 points, obtain the distance and travel time.
      # Refer to: https://developers.google.com/maps/documentation/distance-matrix/distance-matrix
      # @param  origin      [String]  Can be addresses or coordinate.
      # @param  destination [String]  Can be addresses or coordinate.
      # @option mode        [String]  Possible values are ['driving', 'walking', 'transit', 'bicycling']
      def distance_matrix(origin, destination, mode = 'driving')
        response = @http.get('/maps/api/distancematrix/json', params: {
                               destinations: destination,
                               origins: origin,
                               mode: mode,
                               key: @secret
                             })

        raise HTTPError.new(response.status.to_s), 'by GoogleMapsAPI::DistanceMatrix' unless response.status.success?

        unless response.parse['error_message'].nil?
          raise HTTPError.new(response.parse['error_message']),
                'by GoogleMapsAPI'
        end

        response.parse
      end

      # Given a string, obtain the longitude, latitude of the location.
      # Refer to: https://developers.google.com/maps/documentation/geocoding/requests-geocoding
      # @param address      [String] String of your address
      def geocoding(address)
        response = @http.get('/maps/api/geocode/json', params: {
                               address: address,
                               key: @secret
                             })

        raise HTTPError.new(response.status.to_s), 'by GoogleMapsAPI::Geocoding' unless response.status.success?

        unless response.parse['error_message'].nil?
          raise HTTPError.new(response.parse['error_message']),
                'by GoogleMapsAPI'
        end

        response.parse
      end
    end
  end
end
