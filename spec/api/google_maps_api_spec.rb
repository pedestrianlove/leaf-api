# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative '../../lib/services/google_maps_api'
require_relative '../../lib/services/api_errors'

CORRECT_SECRETS = YAML.safe_load_file('config/secrets.yaml')
BAD_SECRETS = YAML.safe_load_file('config/secrets.yaml.example')
CORRECT_RESPONSE = [
  YAML.safe_load_file('spec/fixtures/google_maps_distance_matrix-results.yaml'),
  YAML.safe_load_file('spec/fixtures/google_maps_geocoding-results.yaml')
].freeze

describe 'Test Google API library' do
  describe 'API Authentication Failed' do
    it 'Raise errors when provided with incorrect token on distance matrix.' do
      _(proc do
        GoogleMapsAPI.new(BAD_SECRETS['GOOGLE_TOKEN'])
                     .distance_matrix('光明里 300, Hsinchu City, East District', '24.8022,120.9901', 'walking')
      end).must_raise HTTPError
    end

    it 'Raise errors when provided with incorrect token on distance matrix.' do
      _(proc do
        GoogleMapsAPI.new(BAD_SECRETS['GOOGLE_TOKEN'])
                     .geocoding('光明里 300, Hsinchu City, East District')
      end).must_raise HTTPError
    end
  end

  describe 'API Authentication Succeed' do
    it 'Receive correct data for distance matrix.' do
      payload = GoogleMapsAPI.new(CORRECT_SECRETS['GOOGLE_TOKEN'])
                             .distance_matrix('光明里 300, Hsinchu City, East District', '24.8022,120.9901', 'walking')
      _(payload['destination_addresses'][0]).must_equal CORRECT_RESPONSE[0]['destination_addresses'][0]
      _(payload['origin_addresses'][0]).must_equal CORRECT_RESPONSE[0]['origin_addresses'][0]
      _(payload['rows'][0]['elements'][0]).wont_be_nil
      _(payload['rows'][0]['elements'][0]['distance']).wont_be_nil
      _(payload['rows'][0]['elements'][0]['duration']).wont_be_nil
    end

    it 'Receive correct data for geocoding.' do
      payload = GoogleMapsAPI.new(CORRECT_SECRETS['GOOGLE_TOKEN'])
                             .geocoding('光明里 300, Hsinchu City, East District')
      _(payload['results'][0]['formatted_address'])
        .must_equal CORRECT_RESPONSE[1]['results'][0]['formatted_address']
      _(payload['results'][0]['geometry']['location'])
        .wont_be_nil
      _(payload['results'][0]['geometry']['location']['lat'])
        .must_equal CORRECT_RESPONSE[1]['results'][0]['geometry']['location']['lat']
      _(payload['results'][0]['geometry']['location']['lng'])
        .must_equal CORRECT_RESPONSE[1]['results'][0]['geometry']['location']['lng']
    end
  end
end
