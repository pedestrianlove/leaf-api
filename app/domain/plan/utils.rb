# frozen_string_literal: true

module Leaf
  module Plan
    # Utility methods for calculating distances
    module Utils
      EARTH_RADIUS_MILES = 3958.8 # Radius of Earth in miles
      DEGREE_TO_RADIAN = Math::PI / 180

      # Calculate the distance in meters between two points specified by latitude and longitude
      def self.calculate_distance(origin, destination)
        return 0 unless origin && destination # Guard clause for invalid input

        haversine_data = prepare_haversine_data(origin, destination)
        1000 * calculate_haversine_distance(haversine_data)
      end

      # Converts two latitudes from degrees to radians
      def self.to_radians(origin_lat, destination_lat)
        [origin_lat * DEGREE_TO_RADIAN, destination_lat * DEGREE_TO_RADIAN]
      end

      # Converts the difference in longitude from degrees to radians
      def self.to_radians_longitude(destination_lon, origin_lon)
        (destination_lon - origin_lon) * DEGREE_TO_RADIAN
      end

      # Prepares the Haversine data needed for calculation
      def self.prepare_haversine_data(origin, destination)
        origin_lat_rad, dest_lat_rad = to_radians(origin.latitude, destination.latitude)
        lat_diff = dest_lat_rad - origin_lat_rad
        lon_diff = to_radians_longitude(destination.longitude, origin.longitude)

        HaversineData.new(lat_diff, lon_diff, origin_lat_rad, dest_lat_rad)
      end

      # Calculate Haversine distance using HaversineData struct
      def self.calculate_haversine_distance(haversine_data)
        2 * EARTH_RADIUS_MILES * Math.asin(Math.sqrt(haversine_formula(haversine_data)))
      end

      # Helper method for the Haversine formula
      def self.haversine_formula(haversine_data)
        sin_lat_diff = Math.sin(haversine_data.lat_diff / 2)**2
        cos_lat_product = Math.cos(haversine_data.origin_lat_rad) * Math.cos(haversine_data.dest_lat_rad)
        sin_lon_diff = Math.sin(haversine_data.lon_diff / 2)**2

        sin_lat_diff + (cos_lat_product * sin_lon_diff)
      end

      # Struct to encapsulate data needed for Haversine calculation
      HaversineData = Struct.new(:lat_diff, :lon_diff, :origin_lat_rad, :dest_lat_rad)
    end
  end
end
