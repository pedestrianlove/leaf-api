# frozen_string_literal: true

require 'http'
require 'json'

# Module for storing entire app
module Leaf
  # Class for reporting progress to faye ws server
  class ProgressReporter
    def initialize(config, channel_id)
      @config = config
      @channel_id = channel_id
    end

    def report(progress, message = '')
      puts "Reporting progress #{progress}%, with message #{message} to Faye."
      HTTP.headers(content_type: 'application/json')
          .post(
            "#{@config.API_URL}/faye",
            json: message_body({ progress: progress, message: message })
          )
    rescue HTTP::ConnectionError
      puts '(Faye server not found, progress not sent)'
    end

    def self.report_progress(config, id, progress, msg)
      reporter = ProgressReporter.new(config, id)
      reporter.report(progress, msg)
    end

    private

    def message_body(message)
      {
        channel: "/#{@channel_id}",
        data: message
      }
    end
  end
end
