# frozen_string_literal: true

require_relative '../../../spec_helper'

describe 'Test Google API library' do
  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('google_api', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
  end

  after do
    VCRHelper.eject_vcr
  end

  describe 'API Authentication Failed' do
    it 'Raise errors when provided with incorrect token on distance matrix.' do
      _(proc do
        Leaf::GoogleMaps::API.new(BAD_SECRETS['GOOGLE_TOKEN'])
                     .distance_matrix('光明里 300, Hsinchu City, East District', '24.8022,120.9901', 'walking')
      end).must_raise Leaf::HTTPError
    end

    it 'Raise errors when provided with incorrect token on distance matrix.' do
      _(proc do
        Leaf::GoogleMaps::API.new(BAD_SECRETS['GOOGLE_TOKEN'])
                     .geocoding('光明里 300, Hsinchu City, East District')
      end).must_raise Leaf::HTTPError
    end

    it 'Raise errors when provided with incorrect token on distance matrix.' do
      _(proc do
        Leaf::GoogleMaps::API.new(BAD_SECRETS['GOOGLE_TOKEN'])
                     .plus_code('光明里 300, Hsinchu City, East District')
      end).must_raise Leaf::HTTPError
    end
  end

  describe 'API Authentication Succeed' do
    it 'Receive correct data for distance matrix.' do
      correct_response = YAML.safe_load_file('spec/fixtures/google_maps_distance_matrix-results.yaml')

      payload = Leaf::GoogleMaps::API.new(CORRECT_SECRETS.GOOGLE_TOKEN)
                                     .distance_matrix(
                                       '光明里 300, Hsinchu City, East District',
                                       '24.8022,120.9901',
                                       'walking'
                                     )
      _(payload['destination_addresses'][0]).must_equal correct_response['destination_addresses'][0]
      _(payload['origin_addresses'][0]).must_equal correct_response['origin_addresses'][0]
      _(payload['rows'][0]['elements'][0]).wont_be_nil
      _(payload['rows'][0]['elements'][0]['distance']).wont_be_nil
      _(payload['rows'][0]['elements'][0]['duration']).wont_be_nil
    end

    it 'Receive correct data for geocoding.' do
      correct_response = YAML.safe_load_file('spec/fixtures/google_maps_geocoding-results.yaml')
      payload = Leaf::GoogleMaps::API.new(CORRECT_SECRETS.GOOGLE_TOKEN)
                                     .geocoding('光明里 300, Hsinchu City, East District')
      _(payload['results'][0]['formatted_address'])
        .must_equal correct_response['results'][0]['formatted_address']
      _(payload['results'][0]['geometry']['location'])
        .wont_be_nil
      _(payload['results'][0]['geometry']['location']['lat'])
        .must_equal correct_response['results'][0]['geometry']['location']['lat']
      _(payload['results'][0]['geometry']['location']['lng'])
        .wont_be_nil
    end

    it 'Receive correct data for plus code.' do
      payload = Leaf::GoogleMaps::API.new(CORRECT_SECRETS.GOOGLE_TOKEN)
                                     .plus_code('光明里 300, Hsinchu City, East District')

      _(payload['plus_code']['global_code']).must_be_instance_of String
    end
  end
end
