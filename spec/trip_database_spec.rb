# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests of Trip ORM and Database' do
  before do
    DatabaseHelper.wipe_database
  end

  let(:origin_location) do
    Leaf::Database::LocationOrm.create(
      name: 'North Gate',
      latitude: 24.7957,
      longitude: 120.9925,
      plus_code: '7QP2QXQR+XR'
    )
  end

  let(:destination_location) do
    Leaf::Database::LocationOrm.create(
      name: 'South Gate',
      latitude: 24.7869,
      longitude: 120.9884,
      plus_code: '7QP2QXQR+XA'
    )
  end

  let(:query_id) { SecureRandom.uuid } # Generate a random query_id for testing

  describe 'Create and retrieve trip' do
    it 'HAPPY: should create a new trip and retrieve it from the database' do
      trip = Leaf::Database::TripOrm.create(
        origin_id: origin_location.id,
        destination_id: destination_location.id,
        strategy: 'walking',
        duration: 600,
        distance: 1500,
        query_id: query_id
      )

      found_trip = Leaf::Database::TripOrm.first(id: trip.id)

      expect(found_trip).wont_be_nil
      expect(found_trip.origin_id).must_equal origin_location.id
      expect(found_trip.destination_id).must_equal destination_location.id
      expect(found_trip.strategy).must_equal 'walking'
      expect(found_trip.duration).must_equal 600
      expect(found_trip.distance).must_equal 1500
      expect(found_trip.query_id).must_equal query_id
    end
  end

  describe 'Update trip' do
    it 'HAPPY: should update the strategy of an existing trip' do
      trip = Leaf::Database::TripOrm.create(
        origin_id: origin_location.id,
        destination_id: destination_location.id,
        strategy: 'walking',
        duration: 600,
        distance: 1500,
        query_id: query_id
      )

      trip.update(strategy: 'driving')
      updated_trip = Leaf::Database::TripOrm.first(id: trip.id)

      expect(updated_trip.strategy).must_equal 'driving'
      expect(updated_trip.query_id).must_equal query_id
    end
  end

  describe 'Delete trip' do
    it 'HAPPY: should delete a trip and ensure it is removed from the database' do
      trip = Leaf::Database::TripOrm.create(
        origin_id: origin_location.id,
        destination_id: destination_location.id,
        strategy: 'walking',
        duration: 600,
        distance: 1500,
        query_id: query_id
      )

      trip_id = trip.id
      trip.destroy
      expect(Leaf::Database::TripOrm.first(id: trip_id)).must_be_nil
    end
  end

  describe 'Associations' do
    it 'HAPPY: should access origin and destination locations through associations' do
      trip = Leaf::Database::TripOrm.create(
        origin_id: origin_location.id,
        destination_id: destination_location.id,
        strategy: 'walking',
        duration: 600,
        distance: 1500,
        query_id: query_id
      )

      expect(trip.origin.name).must_equal 'North Gate'
      expect(trip.destination.name).must_equal 'South Gate'
      expect(trip.query_id).must_equal query_id
    end
  end
end
