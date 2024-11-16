# frozen_string_literal: true

module Views
  # View for a Trip
  class Trip
    def initialize(trip)
      @trip = trip
    end

    def origin_name
      @trip.origin.name
    end

    def destination_name
      @trip.destination.name
    end

    def strategy
      @trip.strategy.capitalize
    end

    def distance
      "#{@trip.distance} km"
    end

    def duration
      "#{@trip.duration / 60} minutes"
    end

    def formatted_summary
      "From #{origin_name} to #{destination_name} (#{strategy}): #{distance}, #{duration}"
    end
  end
end
