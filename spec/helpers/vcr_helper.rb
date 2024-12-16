# frozen_string_literal: true

require 'vcr'
require 'webmock'

module VCRHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'

  def self.setup_vcr
    VCR.configure do |vcr_config|
      vcr_config.cassette_library_dir = CASSETTES_FOLDER
      vcr_config.hook_into :webmock
      vcr_config.ignore_localhost = true # for acceptance tests
      vcr_config.ignore_hosts 'sqs.us-east-1.amazonaws.com'
    end
  end

  def self.configure_sensitive_data(token_name, token)
    VCR.configure do |vcr_config|
      vcr_config.filter_sensitive_data("<#{token_name}>") { token }
      vcr_config.filter_sensitive_data("<#{token_name}_ESC>") { CGI.escape(token) }
    end
  end

  def self.configure_vcr_for(gateway_name, token_name = nil, token = nil)
    configure_sensitive_data(token_name, token) if token_name
    insert_cassette(gateway_name)
  end

  def self.insert_cassette(gateway_name)
    VCR.insert_cassette(gateway_name, record: :new_episodes, match_requests_on: %i[method uri headers])
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
