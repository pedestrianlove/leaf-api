# frozen_string_literal: true

module Leaf
  module Plan
    # this is method for plan
    module Utils
      R = 3958.8

      # calculate distance between origin and destination
      def self.calculate_distance(origin, destination)
        return 0 if origin.nil? || destination.nil? # if invalid input

        rlat1, rlat2 = to_radians(origin.latitude, destination.latitude)
        difflat = rlat2 - rlat1
        difflon = to_radians_longitude(destination.longitude, origin.longitude)

        1000 * calculate_haversine_distance(difflat, difflon, rlat1, rlat2)
      end

      def self.to_radians(lat1, lat2)
        [lat1 * (Math::PI / 180), lat2 * (Math::PI / 180)]
      end

      def self.to_radians_longitude(lon1, lon2)
        (lon1 - lon2) * (Math::PI / 180)
      end

      def self.calculate_haversine_distance(difflat, difflon, rlat1, rlat2)
        2 * R * Math.asin(
          Math.sqrt(
            (Math.sin(difflat / 2)**2) +
            (Math.cos(rlat1) * Math.cos(rlat2) * (Math.sin(difflon / 2)**2))
          )
        )
      end
    end
  end
end
