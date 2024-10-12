# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative '../../lib/services/nthu_api'
require_relative '../../lib/services/api_errors'

CORRECT_RESPONSE = [YAML.safe_load_file('spec/fixtures/nthuapi_bus_schedule-results.yaml')].freeze

describe 'Test NTHUAPI library' do
  describe 'API Authentication Suceed' do
    it 'Receive correct data.' do
      payload = NTHUAPI.new.bus_schedule('綜二館', 'main', 'up', 'current')
      _(payload[0]).wont_be_nil
    end
  end
end
