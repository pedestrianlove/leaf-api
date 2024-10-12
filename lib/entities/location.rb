# frozen_string_literal: true

# This is a class to represent the concept of location on the map.
# This may include user's location, bus stop's location, or destination's location.
class Location
  attr_accessor :latitude, :longtitude

  def initialize(latitude, longtitude)
    @latitude = latitude
    @longtitude = longtitude
  end

  def to_s
    "#{@latitude},#{@longtitude}"
  end
end
