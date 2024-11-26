# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module Leaf
  module Requests
    # Trip creation request parser and validator
    class NewTripRequest
      include Dry::Monads::Result::Mixin

      STRATEGY_ARRAY = %w[driving transit bicycling walking].freeze

      def initialize(params)
        @params = params
      end

      def call
        Success(validate(decode_request))
      rescue JSON::ParserError
        Failure(api_error(:bad_request, 'Invalid trip request encoding'))
      rescue StandardError => e
        Failure(api_error(:bad_request, e.message))
      end

      def decode_request
        JSON.parse(Base64.urlsafe_decode64(@params['trip']))
      end

      def self.to_encoded_request(trip_params)
        Base64.urlsafe_encode64(trip_params.to_json)
      end

      def self.to_request(trip_params)
        NewTripRequest.new('trip' => to_encoded_request(trip_params))
      end

      private

      def validate(decoded_request) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        origin, destination, strategy = decoded_request.values_at('origin', 'destination', 'strategy')

        errors = {}
        errors[:origin] = 'Origin is required' if origin.to_s.strip.empty?
        errors[:destination] = 'Destination is required' if destination.to_s.strip.empty?
        errors[:strategy] = 'Invalid strategy' unless STRATEGY_ARRAY.include?(strategy)

        raise StandardError, errors unless errors.empty?

        {
          origin: CGI.unescape(origin),
          destination: CGI.unescape(destination),
          strategy: CGI.unescape(strategy)
        }
      end

      def api_error(status, message)
        { status: status, message: message }
      end
    end
  end
end

# Encoding a Request
# encoded_request = Leaf::Requests::NewTripRequest.to_encoded_request(
#   origin: 'Seattle',
#   destination: 'San Francisco',
#   strategy: 'driving'
# )
# params = { 'trip' => encoded_request }
# request = Leaf::Requests::NewTripRequest.new(params)
# result = request.call
