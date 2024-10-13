# frozen_string_literal: true

require 'http'
require_relative 'api_errors'

module LeafAPI
  module Service
    # This is the service class to make API requests to Nominatim API:
    # https://nominatim.org/release-docs/develop/api/Search/
    class NominatimAPI
      def initialize
        @http = HTTP.accept(:json).persistent('https://nominatim.openstreetmap.org')
      end

      # Perform a search query on Nominatim
      # @param  query [String] The location to search for
      # @option format [String] Possible values: ['json', 'xml', etc.]
      def search(query, format = 'json')
        response = @http.get('/search', params: {
                               q: query,
                               format: format
                             })

        raise HTTPError.new(response.status.to_s), 'by NominatimAPI' unless response.status.success?

        response.parse
      end
    end
  end
end
