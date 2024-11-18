# frozen_string_literal: true

require 'securerandom'
require_relative '../../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../../config/environment'

module Leaf
  # Module handling trip-related routes
  module TripRoutes
    def self.setup(routing) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize,Metrics/PerceivedComplexity
      routing.on 'trips' do # rubocop:disable Metrics/BlockLength
        routing.post 'submit' do
          trip_result = Service::AddTrip.new.call(routing.params)

          if trip_result.success?
            trip_id = trip_result.value!
            routing.session[:visited_trips] ||= []
            routing.session[:visited_trips].unshift(0, trip_id).uniq!
            routing.redirect trip_id
          else
            routing.redirect '/trips'
          end
        end

        routing.is do
          routing.get do
            routing.scope.view 'trip/trip_form'
          end
        end

        routing.on String do |trip_id|
          routing.get do
            trip = Leaf::Repository::Trip.find_by_id(trip_id)
            if trip
              routing.scope.view('trip/trip_result', locals: { trip: trip })
            else
              flash[:error] = MESSAGES[:info_not_found]
              routing.redirect '/trips'
            end
          end

          routing.delete do
            if routing.session[:visited_trips]&.delete(trip_id)
              flash[:notice] = "Trip '#{trip_id}' has been removed from history."
            else
              flash[:error] = MESSAGES[:info_not_found]
            end
            routing.redirect '/trips'
          end
        end
      end
    end
  end
end
