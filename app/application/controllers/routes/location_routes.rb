# frozen_string_literal: true

require_relative '../../../infrastructure/google_maps/mappers/location_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../presentation/representers/location'
require_relative '../../../infrastructure/database/orm/location_orm'

module Leaf
  # Module handling location-related-api routes
  class App < Roda
    plugin :multi_route

    route('locations') do |routing| # rubocop:disable Metrics/BlockLength
      routing.is do # rubocop:disable Metrics/BlockLength
        # POST /locations - Add a new location
        routing.post do
          begin
            params = JSON.parse(routing.body.read)
          rescue JSON::ParserError
            routing.response.status = 400
            return { status: 'bad_request', message: 'Invalid JSON format' }.to_json
          end

          location_name = params['location']
          unless location_name
            routing.response.status = 400
            return { status: 'bad_request', message: 'Missing location name' }.to_json
          end

          # 使用 LocationMapper 查詢地點資訊
          mapper = Leaf::GoogleMaps::LocationMapper.new(
            Leaf::GoogleMaps::API,
            Leaf::App.config.GOOGLE_TOKEN
          )

          begin
            location_data = mapper.find(location_name)
          rescue StandardError
            routing.response.status = 404
            return { status: 'not_found', message: "Location '#{location_name}' not found" }.to_json
          end

          # 檢查地點是否已存在
          existing_location = Leaf::Database::LocationOrm.first(plus_code: location_data.plus_code)
          if existing_location
            routing.response.status = 200
            return Representer::Location.new(existing_location).to_json
          end
          # # 檢查地點是否已存在
          # if Leaf::Database::LocationOrm.first(plus_code: location_data.plus_code)
          #   routing.response.status = 409
          #   return { status: 'conflict',
          #            message: "Location with Plus Code #{location_data.plus_code} already exists" }.to_json
          # end

          # 新增到資料庫
          new_location = Leaf::Database::LocationOrm.find_or_create(
            name: location_data.name,
            plus_code: location_data.plus_code,
            latitude: location_data.latitude,
            longitude: location_data.longitude
          )
          routing.response.status = 201
          { status: 'created', plus_code: new_location.plus_code }.to_json
        end

        # GET /locations - List all locations
        routing.get do
          locations = Leaf::Database::LocationOrm.all.map { |loc| { name: loc.name, plus_code: loc.plus_code } }
          routing.response.status = 200
          { locations: locations }.to_json
        end
      end

      # GET /locations/:plus_code - Get location by Plus Code
      routing.on String do |plus_code|
        routing.get do
          puts "Received Plus Code: #{plus_code}" # 調試輸出
          plus_code = CGI.unescape(plus_code)

          db_location = Leaf::Database::LocationOrm.first(plus_code: plus_code)
          # binding.irb
          if db_location
            puts "Matched Location: #{db_location.inspect}" # 調試輸出
            routing.response.status = 200
            Representer::Location.new(db_location).to_json
          else
            puts 'No Matching Location Found' # 調試輸出
            routing.response.status = 404
            { status: 'not_found', message: "Location with Plus Code '#{plus_code}' not found" }.to_json
          end
        end

        # DELETE /locations/:plus_code - Remove a location by Plus Code
        routing.delete do
          db_location = Leaf::Database::LocationOrm.first(plus_code: CGI.unescape(plus_code))
          if db_location
            db_location.destroy
            routing.response.status = 204
            ''
          else
            routing.response.status = 404
            { status: 'not_found', message: "Location with Plus Code '#{plus_code}' not found" }.to_json
          end
        end
      end
    end
  end
end
