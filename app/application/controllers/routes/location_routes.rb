# frozen_string_literal: true

require_relative '../../../infrastructure/google_maps/mappers/location_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../services/add_location'
require_relative '../../../presentation/representers/location'
require_relative '../../../presentation/representers/location_representer'

module Leaf
  # Module handling location-related routes
  module LocationRoutes
    # :reek:TooManyStatements
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    # :reek:DuplicateMethodCall
    def self.setup(routing) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      # puts 'LocationRoutes setup called!'

      routing.is do # rubocop:disable Metrics/BlockLength
        # Service to handle adding a new location
        # :reek:FeatureEnvy
        # :reek:UncommunicativeVariableName
        # :reek:DuplicateMethodCall
        routing.post do
          # 手動解析 JSON 請求體
          begin
            params = JSON.parse(routing.body.read)
            # puts "Parsed JSON params: #{params.inspect}"
          rescue JSON::ParserError
            routing.response.status = 400
            return { status: 'bad_request', message: 'Invalid JSON format' }.to_json
          end

          req = Leaf::Request::NewLocationRequest.new.call(params)
          if req.failure?
            routing.response.status = 400
            return { status: 'bad_request', message: req.errors.to_h.values.join(', ') }.to_json
          end

          location_query = req[:location].downcase
          result = Leaf::Service::AddLocation.new.call(location_query: location_query)

          if result.failure?
            routing.response.status = 404
            return { status: 'not_found', message: result.failure }.to_json
          end

          location_entity = result.value!
          routing.response.status = 201
          Leaf::Representer::Location.new(location_entity).to_json
        end

        # GET /locations - List all visited locations
        routing.get do
          visited_locations = routing.session[:visited_locations] || []
          routing.response.status = 200
          { locations: visited_locations }.to_json
        end
      end

      routing.on String do |location_query|
        # DELETE /locations/:id - Remove a location
        routing.delete do
          # puts "DELETE /locations/#{location_query}: Session #{routing.session.inspect}"

          # 刪除 session 中的 visited_locations
          if routing.session[:visited_locations]&.delete(location_query)
            # 刪除資料庫中的對應記錄
            db_location = Leaf::Database::LocationOrm.first(name: location_query)
            db_location&.destroy

            routing.session[:visited_locations] = nil if routing.session[:visited_locations].empty?

            routing.response.status = 204
            ''
          else
            routing.response.status = 404
            { status: 'not_found', message: "Location '#{location_query}' not found" }.to_json
          end
        end
      end
    end
  end
end
