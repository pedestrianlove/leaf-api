# frozen_string_literal: true

require 'securerandom'
require_relative '../../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../../config/environment'

module Leaf
  # Module handling plan-related routes
  module QueryRoutes
    def self.setup(routing)
      routing.on 'queries' do
        setup_query_submit(routing)
        setup_query_form(routing)
        setup_query_result(routing)
      end
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.setup_query_submit(routing)
      routing.post 'submit' do
        params = routing.params

        location_mapper = Leaf::GoogleMaps::LocationMapper.new(
          Leaf::GoogleMaps::API,
          Leaf::App.config.GOOGLE_TOKEN
        )

        query = Entity::Query.new({
                                    id: SecureRandom.uuid,
                                    origin: location_mapper.find(params['origin']),
                                    destination: location_mapper.find(params['destination']),
                                    strategy: params['strategy'],
                                    plans: [],
                                    distance: 0,
                                    duration: 0
                                  })

        puts 'start computing'

        query.compute
        puts 'finished computing'

        # Write to database
        puts 'writing to db...'
        Leaf::Repository::Query.save(query)
        puts 'written to db.'

        routing.session[:visited_queries] ||= []
        routing.session[:visited_queries].insert(0, query.id).uniq!

        routing.redirect query.id
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def self.setup_query_form(routing)
      routing.is do
        routing.get do
          routing.scope.view 'query/query_form'
        end
      end
    end
    # rubocop:disable Metrics/MethodLength

    def self.setup_query_result(routing)
      routing.on String do |query_id|
        routing.get do
          query = Leaf::Repository::Query.find_by_id(query_id)
          routing.scope.view('query/query_result', locals: {
                               query: query
                             })
        end
        routing.delete do
          routing.session[:visited_queries].delete(query_id)
          routing.flash[:notice] = "Query '#{query_id}' has been removed from history."
          routing.redirect '/queries'
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
