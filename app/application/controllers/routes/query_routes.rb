# frozen_string_literal: true

require_relative '../../../infrastructure/google_maps/mappers/trip_mapper'
require_relative '../../../infrastructure/google_maps/gateways/google_maps_api'
require_relative '../../../../config/environment'
require_relative '../../../presentation/representers/query_create_result'
require_relative '../../../presentation/representers/query'

module Leaf
  # Module handling plan-related routes
  class App < Roda
    plugin :multi_route
    route('queries') do |routing| # rubocop:disable Metrics/BlockLength
      routing.is do
        routing.post do
          begin
            request_json = JSON.parse(routing.body.read)
          rescue JSON::ParserError
            failed_result = APIResponse::ApiResult.new(status: :bad_request, message: 'Roda: Bad JSON format.')
            failed = Representer::HttpResponse.new(failed_result)
            routing.halt failed.http_status_code, failed.to_json
          end

          query_request = Request::NewQuery.new.call(request_json)
          query_result = Service::AddQuery.new.call(query_request)

          if query_result.failure?
            failed = Representer::HttpResponse.new(query_result.failure)
            routing.halt failed.http_status_code, failed.to_json
          end

          http_response = Representer::HttpResponse.new(query_result.value!)
          response.status = http_response.http_status_code

          Representer::QueryCreateResult.new(
            query_result.value!.message
          ).to_json
        end
      end

      routing.on String do |query_id|
        routing.get do
          query_result = Leaf::Service::GetQuery.new.call(query_id)

          if query_result.failure?
            failed = Representer::HttpResponse.new(query_result.failure)
            routing.halt failed.http_status_code, failed.to_json
          end

          http_response = Representer::HttpResponse.new(query_result.value!)
          response.status = http_response.http_status_code

          Representer::Query.new(query_result.value!.message).to_json
        end
        routing.delete do
          routing.session[:visited_queries].delete(query_id)
          routing.flash[:notice] = "Query '#{query_id}' has been removed from history."
          routing.redirect '/queries'
        end
      end
    end
  end
end
