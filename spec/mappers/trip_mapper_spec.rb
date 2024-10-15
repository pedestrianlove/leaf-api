# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test TripMapper' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GOOGLE_TOKEN>') { CORRECT_SECRETS['GOOGLE_TOKEN'] }
    c.filter_sensitive_data('<GOOGLE_TOKEN_ESC>') { CGI.escape(CORRECT_SECRETS['GOOGLE_TOKEN']) }
  end

  before do
    VCR.insert_cassette 'entity_trip',
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Test duration method' do
    %w[walking driving bicycling transit].each do |strategy|
      it "Return trip duration for #{strategy} travel strategy." do
        trip_mapper = LeafAPI::GoogleMaps::TripMapper.new(
          LeafAPI::GoogleMaps::API,
          CORRECT_SECRETS['GOOGLE_TOKEN']
        )
        trip = trip_mapper.find(
          '光明里 300, Hsinchu City, East District',
          '24.8022,120.9901',
          strategy
        )

        _(trip.duration).must_be_instance_of Integer
        _(trip.distance).must_be_instance_of Integer
        _(trip.strategy).must_equal strategy

        # TODO: Uncomment this after implementing LocationMapper
        # _(trip.origin).must_be_kind_of LeafAPI::Entity::Location
        # _(trip.destination).must_be_kind_of LeafAPI::Entity::Location
      end
    end
  end
end
