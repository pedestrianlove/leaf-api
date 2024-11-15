# frozen_string_literal: true

require_relative 'query'

module Views
  # View for a query in the list
  class QueryList
    include Enumerable

    def initialize(queries)
      @queries = queries.map.with_index do |query, index|
        Querie.new(query, index)
      end
    end

    def each(&)
      @queries.each(&)
    end

    def any?
      @queries.any?
    end

    def count
      @queries.size
    end

    def queries_summary
      @queries.map(&:plans_summary)
    end

    def formatted_queries_summary
      return ['No queries available.'] if @queries.empty?

      @queries.map(&:summary)
    end
  end
end
