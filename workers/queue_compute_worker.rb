# frozen_string_literal: true

require_relative '../require_app'
require_app
require 'figaro'
require 'shoryuken'
require 'shoryuken/options'
require 'aws-sdk-sqs'

# Class for worker fetching the query from SQS
class QueryComputeWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.WORKER_QUEUE, auto_delete: true, body_parser: JSON

  def perform(_sqs_msg, request)
    result = Leaf::Service::AddQuery.new.call(request)
    puts result
  end
end
