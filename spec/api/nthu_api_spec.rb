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
      payload = NTHUAPI.new.bus_schedule('北校門口', 'main', 'up', 'all')[0]
      _(payload).wont_be_nil
      formatted_payload = payload.is_a?(Hash) ? [payload] : payload
      _(formatted_payload).must_equal CORRECT_RESPONSE
    end
  end
end
