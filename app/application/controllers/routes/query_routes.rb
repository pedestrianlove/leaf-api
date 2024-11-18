# frozen_string_literal: true

require 'securerandom'
require_relative '../../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../../config/environment'
require_relative '../../../presentation/view_objects/query'

module Leaf
  # Module handling plan-related routes
  module QueryRoutes
    # :reek:TooManyStatements
    def self.setup(routing) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      routing.on 'queries' do # rubocop:disable Metrics/BlockLength
        routing.post 'submit' do
          query_request = Forms::NewQuery.new.call(routing.params)
          query_result = Service::AddQuery.new.call(query_request)

          if query_result.failure?
            puts(query_result.failure)
            # routing.flash[:error] = query_result.failure
            routing.redirect '/queries'
          end

          query_id = query_result.value!
          routing.session[:visited_queries] ||= []
          routing.session[:visited_queries].insert(0, query_id).uniq!
          # routing.flash[:notice] = "Query #{query_id} created."
          routing.redirect query_id
        end

        routing.is do
          routing.get do
            routing.scope.view 'query/query_form'
          end
        end

        routing.on String do |query_id|
          routing.get do
            query = Leaf::Repository::Query.find_by_id(query_id)
            query_view = Views::Query.new(query)
            routing.scope.view('query/query_result', locals: { query: query_view })
          end
          routing.delete do
            routing.session[:visited_queries].delete(query_id)
            routing.flash[:notice] = "Query '#{query_id}' has been removed from history."
            routing.redirect '/queries'
          end
        end
      end
    end
  end
end
