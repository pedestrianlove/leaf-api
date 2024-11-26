# frozen_string_literal: true

require 'roda'
require 'slim'
require 'rack'
require_relative 'routes/location_routes'
require_relative 'routes/trip_routes'
require_relative 'routes/query_routes'
require_relative '../../presentation/responses/api_result'
require_relative '../../presentation/representers/http_response_representer'
require_relative '../../../config/environment'

module Leaf
  # This is the main application class that handles routing in Leaf
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :multi_route
    use Rack::MethodOverride

    MESSAGES = {
      no_info: 'No info input',
      db_error: 'Database access error',
      info_not_found: 'Info not found',
      invalid_request: 'Invalid request parameters',
      missing_session: 'Session data is missing',
      route_error: 'Unexpected route error',
      unauthorized_access: 'Unauthorized access attempt'
    }.freeze

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        message = "Leaf API v1 at / in #{App.environment} mode"

        result_response = Leaf::Representer::HttpResponse.new(
          Leaf::APIResponse::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.multi_route

      # TODO: 分檔放routes的方法請使用hash_branches:
      # https://roda.jeremyevans.net/rdoc/files/README_rdoc.html#label-hash_branches+plugin
      # https://fiachetti.gitlab.io/mastering-roda/#routing
    end
  end
end
