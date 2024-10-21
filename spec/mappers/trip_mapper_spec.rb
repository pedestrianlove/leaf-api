# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test TripMapper' do
  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('entity_trip', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
  end

  after do
    VCRHelper.eject_vcr
  end

  describe 'Test duration method' do
    %w[walking driving bicycling transit].each do |strategy|
      it "Return trip duration for #{strategy} travel strategy." do
        trip_mapper = LeafAPI::GoogleMaps::TripMapper.new(
          LeafAPI::GoogleMaps::API,
          CORRECT_SECRETS.GOOGLE_TOKEN
        )
        trip = trip_mapper.find(
          '光明里 300, Hsinchu City, East District',
          '24.8022,120.9901',
          strategy
        )

        _(trip.duration).must_be_instance_of Integer
        _(trip.distance).must_be_instance_of Integer
        _(trip.strategy).must_equal strategy

        _(trip.origin).must_be_kind_of LeafAPI::Entity::Location
        _(trip.destination).must_be_kind_of LeafAPI::Entity::Location
      end
    end
  end
end
