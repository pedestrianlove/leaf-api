# frozen_string_literal: true

require 'securerandom'
require_relative '../../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../presentation/representers/trip'
require_relative '../../../../config/environment'

module Leaf
  # Module handling trip-related routes
  class App < Roda
    plugin :multi_route
    plugin :flash

    route('trip') do |router| # rubocop:disable Metrics/BlockLength
      router.post do
        trip_result = Service::AddTrip.new.call(router.params)
        if trip_result.success?
          trip_id = trip_result.value!
          response.status = 201
          { status: 'success', trip_id: trip_id }.to_json
        else
          response.status = 400
          { status: 'error', message: trip_result.failure }.to_json
        end
      end

      router.is do
        router.get do
          response.status = 200
          { status: 'success', message: 'Trip form loaded' }.to_json
        end
      end

      router.on String do |trip_id|
        router.get do
          trip = Leaf::Repository::Trip.find_by_id(trip_id)
          if trip
            trip_json = Leaf::Representers::Trip.new(trip).to_json
            response.status = 200
            trip_json
          else
            response.status = 404
            { status: 'error', message: 'Trip not found' }.to_json
          end
        end
      end
    end
  end
end
