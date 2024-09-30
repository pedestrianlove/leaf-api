# frozen_string_literal: true

require 'yaml'
require_relative './services/nthu_api'
require_relative './services/google_maps_api'

def save_yaml(name, result)
  File.write("spec/fixtures/#{name}.yaml", result.to_yaml)
end

# NTHUSA API
nthu = NTHUAPI.new
save_yaml('nthuapi_bus_schedule', nthu.bus_schedule('綜二', 'main', 'up', 'current')[0])

# Google Maps API
google = GoogleMapsAPI.new
save_yaml('google_maps_distance_matrix',
          google.distance_matrix('光明里 300, Hsinchu City, East District', '24.8022,120.9901', 'walking'))
