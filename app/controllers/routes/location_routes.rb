# frozen_string_literal: true

require_relative '../../infrastructure/google_maps/mappers/location_mapper'
require_relative '../../infrastructure/google_maps/gateways/google_maps_api'

module Leaf
  # Module handling location-related routes
  module LocationRoutes
    def self.setup(routing)
      routing.on 'locations' do
        setup_location_search(routing)
        setup_location_form(routing)
        setup_location_result(routing)
      end
    end

    def self.setup_location_search(routing)
      routing.post 'search' do
        location_query = routing.params['location'].downcase
        # 新增地點到 session 中
        routing.session[:visited_locations] ||= []
        routing.session[:visited_locations].insert(0, location_query).uniq!
        routing.redirect "/locations/#{CGI.escape(location_query)}"
      end
    end

    def self.setup_location_form(routing)
      routing.is do
        routing.get do
          routing.scope.view('location/location_form')
        end
      end
    end

    def self.setup_location_result(routing)
      routing.on String do |location_query|
        routing.get do
          handle_location_query(routing, location_query)
        end
        routing.delete do
          routing.session[:visited_locations].delete(location_query)
          routing.flash[:notice] = "Location '#{location_query}' has been removed from history."

          routing.redirect '/locations'
        end
      end
    end

    def self.handle_location_query(routing, location_query)
      location_entity = Leaf::GoogleMaps::LocationMapper.new(
        Leaf::GoogleMaps::API,
        Leaf::App.config.GOOGLE_TOKEN
      ).find(location_query)

      routing.scope.view('location/location_result', locals: { location: location_entity })
    end
  end
end
