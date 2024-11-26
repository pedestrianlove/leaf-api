# frozen_string_literal: true

require 'securerandom'
require_relative '../../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../../config/environment'

module Leaf
  # Module handling trip-related routes
  module TripRoutes
    plugin :multi_route

    route('trip') do |r| # rubocop:disable Metrics/BlockLength
      r.post 'submit' do
        trip_result = Service::AddTrip.new.call(r.params)

        if trip_result.success?
          trip_id = trip_result.value!
          r.session[:visited_trips] ||= []
          r.session[:visited_trips].unshift(trip_id).uniq!
          r.redirect trip_id
        else
          r.redirect '/trips'
        end
      end

      r.is do
        r.get do
          r.scope.view 'trip/trip_form'
        end
      end

      r.on String do |trip_id|
        r.get do
          trip = Leaf::Repository::Trip.find_by_id(trip_id)
          if trip
            r.scope.view('trip/trip_result', locals: { trip: trip })
          else
            flash[:error] = MESSAGES[:info_not_found]
            r.redirect '/trips'
          end
        end

        r.delete do
          if r.session[:visited_trips]&.delete(trip_id)
            flash[:notice] = "Trip '#{trip_id}' has been removed from history."
          else
            flash[:error] = MESSAGES[:info_not_found]
          end
          r.redirect '/trips'
        end
      end
    end
  end
end

#     def self.setup(routing)
#       routing.on 'trips' do
#         routing.post 'submit' do
#           trip_result = Service::AddTrip.new.call(routing.params)

#           if trip_result.success?
#             trip_id = trip_result.value!
#             routing.session[:visited_trips] ||= []
#             routing.session[:visited_trips].unshift(0, trip_id).uniq!
#             routing.redirect trip_id
#           else
#             routing.redirect '/trips'
#           end
#         end

#         routing.is do
#           routing.get do
#             routing.scope.view 'trip/trip_form'
#           end
#         end

#         routing.on String do |trip_id|
#           routing.get do
#             trip = Leaf::Repository::Trip.find_by_id(trip_id)
#             if trip
#               routing.scope.view('trip/trip_result', locals: { trip: trip })
#             else
#               flash[:error] = MESSAGES[:info_not_found]
#               routing.redirect '/trips'
#             end
#           end

#           routing.delete do
#             if routing.session[:visited_trips]&.delete(trip_id)
#               flash[:notice] = "Trip '#{trip_id}' has been removed from history."
#             else
#               flash[:error] = MESSAGES[:info_not_found]
#             end
#             routing.redirect '/trips'
#           end
#         end
#       end
#     end
#   end
# end
