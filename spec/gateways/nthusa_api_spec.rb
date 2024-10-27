# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test NTHUAPI library' do
  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('nthu_api')
  end

  after do
    VCRHelper.eject_vcr
  end

  describe 'API Authentication Suceed' do
    it 'Receive correct data.' do
      correct_response = [YAML.safe_load_file('spec/fixtures/nthuapi_bus_schedule-results.yaml')].freeze
      payload = LeafAPI::NTHUSA::API.new.bus_schedule('北校門口', 'main', 'up', 'all')[0]
      _(payload).wont_be_nil
      formatted_payload = payload.is_a?(Hash) ? [payload] : payload
      _(formatted_payload).must_equal correct_response
    end
  end
end
