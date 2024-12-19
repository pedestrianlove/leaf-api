# frozen_string_literal: true

require 'securerandom'
require 'dry/transaction'
require 'json'
require 'concurrent'
require_relative '../../presentation/responses/api_result'
require_relative '../../infrastructure/messaging/queue'

module Leaf
  module Service
    # :reek:FeatureEnvy
    # :reek:UncommunicativeVariableName
    class DispatchQuery
      include Dry::Transaction

      step :check_bus
      step :parse_input
      step :dispatch_query

      private

      def check_bus(input) # rubocop:disable Metrics/MethodLength
        schedules = %w[up down].map do |direction|
          Concurrent::Promise.execute { Leaf::NTHUSA::API.new.bus_detailed_schedule('main', direction, 'current') }
        end.map(&:value)

        if schedules.all?(&:empty?)
          return Failure(APIResponse::ApiResult.new(status: :internal_error,
                                                    message: 'Checking service: out of service bruh.'))
        end

        Success(input)
      rescue StandardError
        Failure(APIResponse::ApiResult.new(status: :bad_request,
                                           message: 'Checking service: Failed to connect to API'))
      end

      def parse_input(input)
        if input.success?

          Success(OpenStruct.new(id: SecureRandom.uuid,
                                 origin: input[:origin],
                                 destination: input[:destination],
                                 strategy: input[:strategy]))
        else
          Failure(APIResponse::ApiResult.new(status: :bad_request,
                                             message: "Parsing query: #{input.errors.messages.first}"))
        end
      end

      def dispatch_query(input)
        queue = Messaging::Queue.new(App.config.WORKER_QUEUE_URL, App.config)
        queue.send(input.to_h)

        Success(APIResponse::ApiResult.new(status: :processing, message: input))
      rescue StandardError => e
        Failure(APIResponse::ApiResult.new(status: :internal_error,
                                           message: "Dispatching query: #{e}"))
      end
    end
  end
end
