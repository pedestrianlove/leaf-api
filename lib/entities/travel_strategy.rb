# frozen_string_literal: true

# This module include all kinds of travel strategies.
module TravelStrategy
  module Errors
    class UnknownStrategyError < StandardError; end
    class NotABusStopError < StandardError; end
  end

  LIST = {
    'walking' => WalkingStrategy,
    'driving' => DrivingStrategy,
    'transit' => TransitStrategy,
    'bicycling' => CyclingStrategy,
    'school_bus' => SchoolBusStrategy
  }.freeze

  def choose(strategy)
    raise UnknownStrategyError unless LIST.include? strategy

    LIST[strategy]
  end

  # Base class for all strategies to ensure they implement compute_duration
  class BaseStrategy
    def duration(starting_point, destination)
      raise NotImplementedError, "#{self.class} must implement compute_duration"
    end

    def to_s
      self.class.name.gsub('Strategy', '').downcase
    end
  end

  # Walking strategy class
  class WalkingStrategy < BaseStrategy
    def duration(starting_point, destination)
      google = GoogleMapsAPI.new
      google.distance_matrix(starting_point, destination, 'walking')
    end
  end

  # Driving strategy class
  class DrivingStrategy < BaseStrategy
    def duration(starting_point, destination)
      google = GoogleMapsAPI.new
      google.distance_matrix(starting_point, destination, 'driving')
    end
  end

  # Transit strategy class
  class TransitStrategy < BaseStrategy
    def duration(starting_point, destination)
      google = GoogleMapsAPI.new
      google.distance_matrix(starting_point, destination, 'transit')
    end
  end

  # Bicycling strategy class
  class BicyclingStrategy < BaseStrategy
    def duration(starting_point, destination)
      google = GoogleMapsAPI.new
      google.distance_matrix(starting_point, destination, 'bicycling')
    end
  end

  # School bus strategy class
  class SchoolBusStrategy < BaseStrategy
    def duration(starting_point, destination); end
  end
end
