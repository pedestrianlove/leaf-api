# frozen_string_literal: true

require_relative '../../../infrastructure/google_maps/mappers/location_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../presentation/representers/location'

module Leaf
  # Module handling location-related-api routes
  class App < Roda
    # :reek:TooManyStatements
    plugin :multi_route
    route('locations') do |routing| # rubocop:disable Metrics/BlockLength
      routing.is do # rubocop:disable Metrics/BlockLength
        # POST /locations - Add a new location
        routing.post do # rubocop:disable Metrics/BlockLength
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
            # puts "Location Data: #{location_data.inspect}" # 調試輸出
          rescue StandardError
            routing.response.status = 404
            return { status: 'not_found', message: "Location '#{location_name}' not found" }.to_json
          end

          # 檢查地點是否已存在
          if Leaf::Database::LocationOrm.first(name: location_data.name)
            routing.response.status = 409
            return { status: 'conflict', message: "#{location_data.name} already exists" }.to_json
          end

          # 新增到資料庫
          new_location = Leaf::Database::LocationOrm.find_or_create(
            name: location_data.name,
            plus_code: location_data.plus_code,
            latitude: location_data.latitude,
            longitude: location_data.longitude
          )
          routing.response.status = 201
          { status: 'created', message: "#{new_location.name} added successfully" }.to_json
        end

        # GET /locations - List all locations
        routing.get do
          locations = Leaf::Database::LocationOrm.all.map(&:name)
          routing.response.status = 200
          { locations: locations }.to_json
        end
      end

      # DELETE /locations/:id - Remove a location
      routing.on String do |location_query|
        routing.delete do
          decoded_name = CGI.unescape(location_query) # 解碼 URI 名稱
          db_location = Leaf::Database::LocationOrm.first(name: decoded_name)
          if db_location
            db_location.destroy
            routing.response.status = 204
            ''
          else
            routing.response.status = 404
            { status: 'not_found', message: "Location '#{decoded_name}' not found" }.to_json
          end
        end
      end
    end
  end
end
