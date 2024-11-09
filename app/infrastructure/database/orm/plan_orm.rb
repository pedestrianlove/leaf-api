# frozen_string_literal: true

require 'sequel'

module Leaf
  module Database
    # Object-Relational Mapper for Trip
    class PlanOrm < Sequel::Model(:plans)
      many_to_one :origin,
                  class: :'Leaf::Database::LocationOrm',
                  key: :origin_id

      many_to_one :destination,
                  class: :'Leaf::Database::LocationOrm',
                  key: :destination_id

      one_to_many :trips,
                  class: :'Leaf::Database::TripOrm',
                  key: :plan_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(plan_info)
        first(
          origin_id: plan_info[:origin_id],
          destination_id: plan_info[:destination_id],
          strategy: plan_info[:strategy],
          duration: plan_info[:duration],
          distance: plan_info[:distance],
          query_id: plan_info[:query_id]
        ) || create(plan_info)
      end
    end
  end
end
