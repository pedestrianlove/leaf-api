# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Plan Entity' do
  VCRHelper.setup_vcr

  before do
    @origin = Leaf::Entity::Location.new(
      id: nil,
      plus_code: '7QP2QXQR+XR',
      name: '清華大學',
      latitude: 24.795707,
      longitude: 120.996393
    )

    @destination = Leaf::Entity::Location.new(
      id: nil,
      plus_code: '7QP2QRQ2+MP',
      name: '交通大學',
      latitude: 24.784834,
      longitude: 120.997929
    )

    @strategy = 'driving'
    @query_id = SecureRandom.uuid # Generate a query_id for the test
    VCRHelper.configure_vcr_for('entity_trip', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
  end

  after do
    VCRHelper.eject_vcr
  end

  it 'Happy: successfully creates a Plan with valid parameters' do
    trip_mapper = Leaf::GoogleMaps::TripMapper.new(
      Leaf::GoogleMaps::API,
      CORRECT_SECRETS.GOOGLE_TOKEN
    )

    trips = []
    3.times do
      trips << trip_mapper.find(@origin.name, @destination.name, @strategy, @query_id)
    end

    travel_plan = Leaf::Entity::Plan.new(
      origin: @origin,
      destination: @destination,
      strategy: @strategy,
      trips: trips,
      distance_to: Leaf::Plan::Utils.calculate_distance(@origin, @destination).to_i,
      query_id: @query_id # Include query_id in the Plan
    )

    _(travel_plan).must_be_kind_of Leaf::Entity::Plan
    _(travel_plan.origin).must_equal @origin
    _(travel_plan.destination).must_equal @destination
    _(travel_plan.strategy).must_equal @strategy
    _(travel_plan.trips.size).must_equal 3
    _(travel_plan.distance_to).must_be_instance_of Integer
    _(travel_plan.distance_to).must_be :>, 0
    _(travel_plan.query_id).must_equal @query_id # Check if query_id is correctly set
  end
end
