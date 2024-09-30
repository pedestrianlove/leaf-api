# frozen_string_literal: true

require 'yaml'
require_relative './services/nthu_api'

def save_yaml(name, result)
  File.write("spec/fixtures/#{name}.yaml", result.to_yaml)
end

# NTHUSA API
nthuapi = NTHUAPI.new
save_yaml('nthuapi_bus_schedule', nthuapi.bus_schedule('綜二', 'main', 'up', 'current')[0])
