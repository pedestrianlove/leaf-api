# frozen_string_literal: true

module Views
  # View for a query
  class Query
    def initialize(query, index = nil)
      @query = query
      @index = index
    end

    def entity
      @query
    end

    def id
      @query.id
    end

    def origin_name
      @query.origin.name
    end

    def destination_name
      @query.destination.name
    end

    def strategy
      @query.strategy.capitalize
    end

    def plans
      @query.plans.map { |plan| Views::Plan.new(plan) }
    end

    def plans_summary
      plans.map(&:summary)
    end

    def formatted_plans_summary
      plans_summary.map { |summary| "Plan: #{summary}" }
    end

    def summary
      "Query ID #{id}: From #{origin_name} to #{destination_name} using #{strategy} strategy."
    end
  end
end
