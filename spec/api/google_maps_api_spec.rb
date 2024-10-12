# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative '../../lib/services/google_maps_api'
require_relative '../../lib/services/api_errors'

CORRECT_SECRETS = YAML.safe_load_file('config/secrets.yaml')
BAD_SECRETS = YAML.safe_load_file('config/secrets.yaml.example')
CORRECT_RESPONSE = YAML.safe_load_file('spec/fixtures/google_maps_distance_matrix-results.yaml')

describe 'Test Google API library' do
  describe 'API Authentication Failed' do
    it 'Raise errors when provided with incorrect token.' do
      _(proc do
        GoogleMapsAPI.new(BAD_SECRETS['GOOGLE_TOKEN'])
                     .distance_matrix('光明里 300, Hsinchu City, East District', '24.8022,120.9901', 'walking')
      end).must_raise HTTPError
    end
  end

  describe 'API Authentication Suceed' do
    it 'Receive correct data.' do
      payload = GoogleMapsAPI.new(CORRECT_SECRETS['GOOGLE_TOKEN'])
                             .distance_matrix('光明里 300, Hsinchu City, East District', '24.8022,120.9901', 'walking')
      _(payload['destination_addresses'][0]).must_equal CORRECT_RESPONSE['destination_addresses'][0]
      _(payload['origin_addresses'][0]).must_equal CORRECT_RESPONSE['origin_addresses'][0]
      _(payload['rows'][0]['elements'][0]).wont_be_nil
      _(payload['rows'][0]['elements'][0]['distance']).wont_be_nil
      _(payload['rows'][0]['elements'][0]['duration']).wont_be_nil
    end
  end
end
