# frozen_string_literal: true

require_relative 'travel_strategy'

# This is a class to represent the concept of trip on the map.
# This may include strategies like 'driving', 'bicycling', 'school_bus', 'walking', 'trasit'...etc.
class Trip
  attr_accessor :starting_point, :destination
  attr_reader :strategy

  include TravelStrategy

  def initialize(starting_point, destination, strategy = 'walking')
    @starting_point = starting_point
    @destination = destination
    @strategy = TravelStrategy.choose(strategy)
  end

  def duration
    @strategy.duration(starting_point.to_s, destination.to_s)
  end
end
