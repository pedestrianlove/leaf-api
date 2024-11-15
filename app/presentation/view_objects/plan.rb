# frozen_string_literal: true

module Views
  # View for a plan
  class Plan
    def initialize(plan, index = nil)
      @plan = plan
      @index = index
    end

    def entity
      @plan
    end

    def id
      @plan.id
    end

    def origin_name
      @plan.origin.name
    end

    def destination_name
      @plan.destination.name
    end

    def strategy
      @plan.strategy.capitalize
    end

    def distance
      "#{@plan.distance} km"
    end

    def duration
      "#{@plan.duration / 60} minutes"
    end

    def trip_details
      @plan.trips.map { |trip| Views::Trip.new(trip) }
    end

    def formatted_trip_details
      trip_details.map(&:formatted_summary)
    end

    def summary
      "Plan from #{origin_name} to #{destination_name} using #{strategy}, covering #{distance} in #{duration}."
    end
  end
end
