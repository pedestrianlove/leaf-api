# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Entity::Trip class' do
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
        trip = LeafAPI::Entity::Trip.new('光明里 300, Hsinchu City, East District', '24.8022,120.9901', strategy)
        _(trip.duration).must_be_instance_of Integer
      end

      it "Return trip duration for #{strategy} travel strategy when provided with Location object." do
        starting_point = LeafAPI::Entity::Location.new(24.8022, 120.9901)
        destination = LeafAPI::Entity::Location.new(24.8134, 120.97101)
        trip = LeafAPI::Entity::Trip.new(starting_point, destination, strategy)
        _(trip.duration).must_be_instance_of Integer
      end
    end
  end
end
