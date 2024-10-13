# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test NTHUAPI library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette 'nthu_api',
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'API Authentication Suceed' do
    it 'Receive correct data.' do
      correct_response = [YAML.safe_load_file('spec/fixtures/nthuapi_bus_schedule-results.yaml')].freeze
      payload = LeafAPI::Service::NTHUAPI.new.bus_schedule('北校門口', 'main', 'up', 'all')[0]
      _(payload).wont_be_nil
      formatted_payload = payload.is_a?(Hash) ? [payload] : payload
      _(formatted_payload).must_equal correct_response
    end
  end
end
