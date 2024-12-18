# frozen_string_literal: true

require_relative 'location'
require_relative 'plan'

module Leaf
  module Repository
    # Repository for Trip
    class Query
      def self.find_by_id(query_id)
        db_record = Leaf::App.db.fetch('SELECT * FROM plans WHERE query_id=? ORDER BY id', query_id)
        return nil unless db_record

        first_record = db_record.first
        Entity::Query.new({
                            id: first_record[:query_id],
                            strategy: first_record[:strategy],
                            origin: Location.find_by_id(first_record[:origin_id]),
                            destination: Location.find_by_id(first_record[:destination_id]),
                            plans: db_record.map { |row| Plan.find_by_id(row[:id]) }
                          })
      end

      def self.save(query)
        query.plans.each do |plan|
          Plan.save(plan, query.id)
        end
      end
    end
  end
end
