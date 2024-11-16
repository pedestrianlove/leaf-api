# frozen_string_literal: true

module Views
  # View for a single location entity
  class Location
    def initialize(location_entity)
      @location = location_entity
    end

    def name
      @location.name # || 'N/A'
    end

    def longitude
      @location.longitude # || 'N/A'
    end

    def latitude
      @location.latitude # || 'N/A'
    end

    def plus_code
      @location.plus_code # || 'N/A'
    end
  end
end
