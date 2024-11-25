# frozen_string_literal: true

module Leaf
  class App < Roda
    plugin :multi_route

    route('locations') do |r|
      r.is do
        r.get do
          message = "Leaf API v1 at / in #{App.environment} mode"

          result_response = Leaf::Representer::HttpResponse.new(
            Leaf::APIResponse::ApiResult.new(status: :ok, message: message)
          )

          response.status = result_response.http_status_code
          result_response.to_json
        end
      end
    end
  end
end
