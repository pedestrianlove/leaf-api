# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative '../../lib/services/nominatim_api'
require_relative '../../lib/services/api_errors'

CORRECT_RESPONSE = YAML.safe_load_file('spec/fixtures/nominatim_serach_nthu-results.yaml')

describe 'Test Nominatim API library' do
  describe 'API Search Succeed' do
    it 'Receive correct data for NTHU search.' do
      nominatim_api = NominatimAPI.new
      payload = nominatim_api.search('清華大學')
      _(payload[0]['place_id']).must_equal CORRECT_RESPONSE[0]['place_id']
      _(payload[0]['name']).must_equal CORRECT_RESPONSE[0]['name']
      _(payload[0]['lat']).must_equal CORRECT_RESPONSE[0]['lat']
      _(payload[0]['lon']).must_equal CORRECT_RESPONSE[0]['lon']
      _(payload[1]['place_id']).must_equal CORRECT_RESPONSE[1]['place_id']
      _(payload[1]['name']).must_equal CORRECT_RESPONSE[1]['name']
      _(payload[1]['lat']).must_equal CORRECT_RESPONSE[1]['lat']
      _(payload[1]['lon']).must_equal CORRECT_RESPONSE[1]['lon']
    end
  end
end
