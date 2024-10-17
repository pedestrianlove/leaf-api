# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test LocationMapper' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GOOGLE_TOKEN>') { CORRECT_SECRETS['GOOGLE_TOKEN'] }
    c.filter_sensitive_data('<GOOGLE_TOKEN_ESC>') { CGI.escape(CORRECT_SECRETS['GOOGLE_TOKEN']) }
  end

  before do
    VCR.insert_cassette 'entity_location',
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Test find method' do
    it 'Returns a Location entity for a valid address' do
      location_mapper = LeafAPI::GoogleMaps::LocationMapper.new(
        LeafAPI::GoogleMaps::API,
        CORRECT_SECRETS['GOOGLE_TOKEN']
      )
      location = location_mapper.find('光明里 300, Hsinchu City, East District')

      _(location).must_be_kind_of LeafAPI::Entity::Location
      _(location.name).must_equal '光明里 300, Hsinchu City, East District'
      _(location.latitude).must_be_instance_of Float
      _(location.longtitude).must_be_instance_of Float
    end
  end
end