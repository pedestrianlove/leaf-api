# frozen_string_literal: true

require 'http'
require 'yaml'

# This is the service class to make API requests to Google Maps API:
# https://api.nthusa.tw/docs
class GoogleMapsAPI
  def initialize
    @http = HTTP.accept(:json).follow.persistent('https://maps.googleapis.com')
    @secret = YAML.safe_load_file('config/secrets.yaml')['GOOGLE_TOKEN']
  end

  # Given 2 points, obtain the distance and travel time.
  # @param origin
  # @param destination
  # @option mode
  def distance_matrix(origin, destination, mode = 'driving')
    @http.get('/maps/api/distancematrix/json', params: {
                destinations: destination,
                origins: origin,
                mode: mode,
                key: @secret
              }).parse
  end
end
