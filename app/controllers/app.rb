# frozen_string_literal: true

require 'roda'
require 'slim'
require_relative '../models/mappers/location_mapper'
require_relative '../models/gateways/google_maps_api'

CORRECT_SECRETS = YAML.safe_load_file('config/secrets.yaml')

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

      # GET /
      routing.root do
        view 'home'
      end

      # Manage Location resources
      routing.on 'locations' do
        # for search (POST /locations/search)
        routing.post 'search' do
          location_query = routing.params['location'].downcase
          routing.redirect "/locations/#{CGI.escape(location_query)}"
        end

        routing.is do
          # show seraching table (GET /locations)
          routing.get do
            view 'location_form'
          end
        end

        # show the searching results (GET /locations/[location_query])
        routing.on String do |location_query|
          routing.get do
            # apply Mapper to get location info
            location_entity = LeafAPI::GoogleMaps::LocationMapper.new(LeafAPI::GoogleMaps::API, CORRECT_SECRETS['GOOGLE_TOKEN']).find(location_query)
            # show the searching results
            view 'location_result', locals: { location: location_entity }
          end
        end
      end

      # Manage Trip resources
      routing.on 'trips' do
        routing.get do
          view 'trip'
        end
      end
    end
  end
end
