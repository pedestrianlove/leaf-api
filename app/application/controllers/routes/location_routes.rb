# frozen_string_literal: true

require_relative '../../../infrastructure/google_maps/mappers/location_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../forms/new_location'
require_relative '../../services/add_location'
require_relative '../../../presentation/view_objects/location'

module Leaf
  # Module handling location-related routes
  module LocationRoutes
    # :reek:TooManyStatements
    def self.setup(routing)
      routing.on 'locations' do
        setup_location_search(routing)
        setup_location_form(routing)
        setup_location_result(routing)
      end
    end

    def self.setup_location_search(routing) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      routing.post 'search' do
        # 使用 Form Object 驗證輸入
        form = Forms::NewLocation.new.call(routing.params)

        if form.failure?
          routing.flash[:error] = form.errors.to_h.values.join(', ')
          routing.redirect '/locations'
        end

        # 對輸入地點進行 URI 編碼
        location_query = CGI.escape(form[:location].downcase)
        puts("Encoded Location Query: #{location_query}")

        # 呼叫 Service Object
        result = Service::AddLocation.new.call(location_query: location_query)
        puts("Service Result: #{result}")

        if result.failure?
          routing.flash[:error] = result.failure
          routing.redirect '/locations'
        else
          location_entity = result.value!
          puts("Location Entity Name: #{location_entity.name}")

          # 儲存最近訪問的地點
          routing.session[:visited_locations] ||= []
          routing.session[:visited_locations].insert(0, location_entity.name).uniq!
          routing.redirect "/locations/#{location_query}"
        end
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
      # 使用 LocationMapper 獲取地點資料
      location_entity = Leaf::GoogleMaps::LocationMapper.new(
        Leaf::GoogleMaps::API,
        Leaf::App.config.GOOGLE_TOKEN
      ).find(location_query)

      puts(location_entity)
      # 將地點資料轉換為 View Object
      location_view = Views::Location.new(location_entity)
      routing.scope.view('location/location_result', locals: { location: location_view })
    end
  end
end
