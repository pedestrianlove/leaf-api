# frozen_string_literal: true

module Views
  # View for a single query entity
  class Query
    def initialize(query)
      @query = query
    end

    def origin_name
      @query.origin.name
    end

    def destination_name
      @query.destination.name
    end

    def strategy
      @query.strategy
    end

    def distance
      @query.plans[0].distance
    end

    def duration
      @query.plans[0].duration / 60
    end
  end
end
