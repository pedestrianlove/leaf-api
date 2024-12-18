# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Leaf
  module Entity
    # for plan
    class Query < Dry::Struct
      include Dry.Types

      attribute :id, Strict::String
      attribute :origin, Location
      attribute :destination, Location
      attribute :strategy, String.enum('driving', 'bicycling', 'school_bus', 'walking', 'transit')
      attribute :plans, Strict::Array.of(Plan).optional

      def to_attr_hash
        to_hash.except(:id)
      end

      def compute # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        # 未來可能會加入讓使用者輸入多種可選的strategy的功能
        final_bus_stop = destination.nearest_bus_stops(1).first
        computed_plans = origin.nearest_bus_stops(3).map do |initial_bus_stop|
          Concurrent::Promise
            .new do
              Plan.new({
                         origin: origin,
                         destination: destination,
                         strategy: strategy,
                         trips: []
                       }).compute(initial_bus_stop, final_bus_stop)
            end.execute
        end

        computed_plans.each do |promise|
          plans.append(promise.value!) # `.value!` waits for and retrieves the result
        end
      end
    end
  end
end
