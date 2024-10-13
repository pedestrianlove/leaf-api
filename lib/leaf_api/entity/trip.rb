# frozen_string_literal: true

require_relative 'travel_strategy'

module LeafAPI
  module Entity
    # This is a class to represent the concept of trip on the map.
    # This may include strategies like 'driving', 'bicycling', 'school_bus', 'walking', 'trasit'...etc.
    class Trip
      attr_reader :starting_point, :destination, :strategy

      include TravelStrategy

      def initialize(starting_point, destination, strategy = 'walking')
        @starting_point = starting_point
        @destination = destination
        @strategy = choose(strategy)
      end

      def duration
        @strategy.duration(starting_point, destination)
      end
    end
  end
end
