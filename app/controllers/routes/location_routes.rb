# frozen_string_literal: true

require_relative '../../models/mappers/location_mapper'
require_relative '../../models/gateways/google_maps_api'
require_relative '../../../config/environment'

module LeafAPI
  # Module handling location-related routes
  module LocationRoutes
    def self.setup(routing, config)
      routing.on 'locations' do
        setup_location_search(routing)
        setup_location_form(routing)
        setup_location_result(routing, config)
      end
    end

    def self.setup_location_search(routing)
      routing.post 'search' do
        location_query = routing.params['location'].downcase
        routing.redirect "/locations/#{CGI.escape(location_query)}"
      end
    end

    def self.setup_location_form(routing)
      routing.is do
        routing.get do
          routing.scope.view('location_form')
        end
      end
    end

    def self.setup_location_result(routing, config)
      routing.on String do |location_query|
        routing.get do
          handle_location_query(routing, location_query, config)
        end
      end
    end

    def self.handle_location_query(routing, location_query, config)
      location_entity = LeafAPI::GoogleMaps::LocationMapper.new(
        LeafAPI::GoogleMaps::API,
        config['GOOGLE_TOKEN']
      ).find(location_query)

      routing.scope.view('location_result', locals: { location: location_entity })
    end
  end
end
