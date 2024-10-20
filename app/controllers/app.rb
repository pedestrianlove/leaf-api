# frozen_string_literal: true

require 'roda'
require 'slim'
require_relative '../models/mappers/location_mapper'
require_relative '../models/gateways/google_maps_api'
require_relative '../../config/environment'

module LeafAPI
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      setup_routes(routing)
    end

    private

    def setup_routes(routing)
      setup_root(routing)
      setup_location_routes(routing)
      setup_trip_routes(routing)
    end

    def setup_root(routing)
      routing.root do
        view 'home'
      end
    end

    def setup_location_routes(routing)
      routing.on 'locations' do
        setup_location_search(routing)
        setup_location_form(routing)
        setup_location_result(routing)
      end
    end

    def setup_location_search(routing)
      routing.post 'search' do
        handle_search(routing)
      end
    end

    def setup_location_form(routing)
      routing.is do
        routing.get do
          view 'location_form'
        end
      end
    end

    def setup_location_result(routing)
      routing.on String do |location_query|
        routing.get do
          handle_location_query(location_query)
        end
      end
    end

    def handle_search(routing)
      location_query = routing.params['location'].downcase
      routing.redirect "/locations/#{CGI.escape(location_query)}"
    end

    def handle_location_query(location_query)
      location_entity = LeafAPI::GoogleMaps::LocationMapper.new(
        LeafAPI::GoogleMaps::API,
        CONFIG['GOOGLE_TOKEN']
      ).find(location_query)

      view 'location_result', locals: { location: location_entity }
    end

    def setup_trip_routes(routing)
      routing.on 'trips' do
        routing.get do
          view 'trip'
        end
      end
    end
  end
end
