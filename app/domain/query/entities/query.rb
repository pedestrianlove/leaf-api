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

      def compute
        # 未來可能會加入讓使用者輸入多種可選的strategy的功能
        plans.append(Plan.new({
                                origin: origin,
                                destination: destination,
                                strategy: strategy,
                                trips: []
                              }).compute)
      end
    end
  end
end
