# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Leaf
  module Entity
    # This is a class to represent the concept of location on the map.
    # This may include user's location, bus stop's location, or destination's location.
    class Location < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional.default(nil)
      attribute :plus_code, Strict::String
      attribute :name, String.optional
      attribute :latitude, Strict::Float.optional
      attribute :longitude, Strict::Float.optional

      def to_attr_hash
        to_hash.except(:id)
      end

      STOP_LIST = [
        Location.new(name: '北校門口', latitude: 24.79589, longitude: 120.99633,
                     plus_code: 'QXWW+9G4 光明里 Hsinchu City, East District'),
        Location.new(name: '綜二館', latitude: 24.794176, longitude: 120.99376,
                     plus_code: 'QXVV+MGC 光明里 Hsinchu City, East District'),
        Location.new(name: '楓林小徑', latitude: 24.791921, longitude: 120.992255,
                     plus_code: 'QXRR+QW6 光明里 Hsinchu City, East District'),
        Location.new(name: '人社院&生科館', latitude: 24.789679, longitude: 120.989975,
                     plus_code: 'QXQQ+VXH 光明里 Hsinchu City, East District'),
        Location.new(name: '台積館', latitude: 24.78695, longitude: 120.9884,
                     plus_code: 'QXPQ+Q9C 仙宮里 Hsinchu City, East District'),
        Location.new(name: '奕園停車場', latitude: 24.788284441920126,
                     longitude: 120.99246131713849, plus_code: 'QXQR+8X8 光明里 Hsinchu City, East District'),
        Location.new(name: '南門停車場', latitude: 24.7859395, longitude: 120.9901396,
                     plus_code: 'QXPR+93C 仙宮里 Hsinchu City, East District')
      ].freeze

      def nearest_bus_stops(number)
        nearest_list = STOP_LIST.sort_by { |stop| distance(latitude, longitude, stop.latitude, stop.longitude) }

        nearest_list.first(number)
      end

      private

      # Return the distance between two points.
      # This is a simple implementation of the Haversine formula.
      # https://en.wikipedia.org/wiki/Haversine_formula
      def distance(lat1, lon1, lat2, lon2) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        r = 6371 # km
        rad = Math::PI / 180
        lat1 *= rad
        lon1 *= rad
        lat2 *= rad
        lon2 *= rad
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = (Math.sin(dlat / 2)**2) + (Math.cos(lat1) * Math.cos(lat2) * (Math.sin(dlon / 2)**2))
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        r * c * 1000 # m
      end
    end
  end
end
